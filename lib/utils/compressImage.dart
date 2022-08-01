import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart';

class _DecodeParams {
  final Uint8List bytes;
  final int width;
  final int height;
  final SendPort sendPort;
  _DecodeParams(this.bytes, this.sendPort, this.width, this.height);
}

void _decodeIsolate(_DecodeParams param) {
  final decodedImage = decodePng(param.bytes)!;

  final jpg = encodeJpg(decodedImage, quality: 75);
  param.sendPort.send(jpg);
}

// Decode and process an image file in a separate thread (isolate) to avoid
// stalling the main UI thread.
Future<Uint8List> compressImage(Uint8List bytes, Size targetDimensions) async {
  var receivePort = ReceivePort();

  // Spawn an Isolate to do the encoding off the main thread.
  await Isolate.spawn(
      _decodeIsolate,
      _DecodeParams(bytes, receivePort.sendPort, targetDimensions.width.toInt(),
          targetDimensions.height.toInt()));

  // Get the processed image from the isolate.
  final jpgBytes = await receivePort.first as Uint8List;

  return jpgBytes;
}
