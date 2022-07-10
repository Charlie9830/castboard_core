import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart';

const kThumbnailFileExt = '.png';

class DecodeParam {
  final File file;
  final SendPort sendPort;
  DecodeParam(this.file, this.sendPort);
}

void decodeIsolate(DecodeParam param) {
  var image = decodeImage(param.file.readAsBytesSync())!;
  var thumbnail = copyResize(image, width: 64);
  param.sendPort.send(thumbnail);
}

// Decode and process an image file in a separate thread (isolate) to avoid
// stalling the main UI thread.
Future<void> createThumbnail(
    {required File sourceFile, required String targetFilePath}) async {
  var receivePort = ReceivePort();

  await Isolate.spawn(
      decodeIsolate, DecodeParam(sourceFile, receivePort.sendPort));

  // Get the processed image from the isolate.
  final image = await receivePort.first as Image;
  final targetFile = File('$targetFilePath$kThumbnailFileExt');
  await targetFile.writeAsBytes(encodePng(image));

  return;
}

class MultiDecodeParam {
  final List<File> files;
  final SendPort sendPort;
  MultiDecodeParam(this.files, this.sendPort);
}

void multiDecodeIsolate(MultiDecodeParam param) {
  final images =
      param.files.map((file) => decodeImage(file.readAsBytesSync())!);
  final thumbnails =
      images.map((image) => copyResize(image, width: 64)).toList();

  param.sendPort.send(thumbnails);
}

Future<void> createThumbnails(
    {required List<File> sourceFiles,
    required List<String> targetFilePaths}) async {
  final receivePort = ReceivePort();

  await Isolate.spawn(
      multiDecodeIsolate, MultiDecodeParam(sourceFiles, receivePort.sendPort));

  final thumbnails = await receivePort.first as List<Image>;

  var index = 0;
  for (var thumb in thumbnails) {
    final targetFile = File('${targetFilePaths[index]}$kThumbnailFileExt');
    await targetFile.writeAsBytes(encodePng(thumb));
    index++;
  }
}
