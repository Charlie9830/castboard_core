import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:stream_channel/isolate_channel.dart';

import 'package:image/image.dart';

class ImageCompressor {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  IsolateChannel? _channel;

  late final StreamController<Uint8List> _outputStreamController;

  ImageCompressor() {
    _outputStreamController = StreamController();
  }

  Stream<Uint8List> get outputStream => _outputStreamController.stream;

  Future<void> spinUp() async {
    _receivePort = ReceivePort();
    _channel = IsolateChannel.connectReceive(_receivePort!);
    _channel!.stream.listen(_handleMessageFromIsolate);

    _isolate =
        await Isolate.spawn(_compressionIsolateWorker, _receivePort!.sendPort);
  }

  void dispatchImageToCompressor(Uint8List data, int width, int height) {
    _channel!.sink.add(_Message(data, width, height));
  }

  void _handleMessageFromIsolate(dynamic data) {
    _outputStreamController.sink.add(data);
  }

  void spinDown() {
    _isolate!.kill();
    _channel!.sink.close();
    _receivePort!.close();
  }
}

class _Message {
  final Uint8List bytes;
  final int width;
  final int height;

  _Message(this.bytes, this.width, this.height);
}

void _compressionIsolateWorker(SendPort sendPort) async {
  final IsolateChannel channel = IsolateChannel.connectSend(sendPort);

  await for (var data in channel.stream) {
    if (data is _Message) {
      final sw = Stopwatch()..start();
      final image = Image.fromBytes(data.width, data.height, data.bytes);
      final jpg = encodeJpg(image, quality: 50);

      print('${sw.elapsedMilliseconds} for ${jpg.length / 1000}');

      channel.sink.add(jpg);
    }
  }
}

// class _DecodeParams {
//   final Uint8List bytes;
//   final int width;
//   final int height;
//   final SendPort sendPort;
//   _DecodeParams(this.bytes, this.sendPort, this.width, this.height);
// }

// void _decodeIsolate(_DecodeParams param) {
//   final decodedImage = decodePng(param.bytes)!;

//   final jpg = encodeJpg(decodedImage, quality: 75);
//   param.sendPort.send(jpg);
// }

// // Decode and process an image file in a separate thread (isolate) to avoid
// // stalling the main UI thread.
// Future<Uint8List> compressImage(Uint8List bytes, Size targetDimensions) async {
//   var receivePort = ReceivePort();

//   // Spawn an Isolate to do the encoding off the main thread.
//   await Isolate.spawn(
//       _decodeIsolate,
//       _DecodeParams(bytes, receivePort.sendPort, targetDimensions.width.toInt(),
//           targetDimensions.height.toInt()));

//   // Get the processed image from the isolate.
//   final jpgBytes = await receivePort.first as Uint8List;

//   return jpgBytes;
// }
