import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:stream_channel/isolate_channel.dart';

import 'package:image/image.dart';

class ImageCompressor {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  IsolateChannel? _channel;
  bool running = false;

  late final StreamController<ImageResult> _outputStreamController;

  ImageCompressor() {
    _outputStreamController = StreamController();
  }

  Stream<ImageResult> get outputStream => _outputStreamController.stream;

  Future<void> spinUp() async {
    _receivePort = ReceivePort();
    _channel = IsolateChannel.connectReceive(_receivePort!);
    _channel!.stream.listen(_handleMessageFromIsolate,
        onError: (e, stacktrace) =>
            _outputStreamController.addError(e, stacktrace));

    _isolate =
        await Isolate.spawn(_compressionIsolateWorker, _receivePort!.sendPort);

    running = true;
  }

  void dispatchImageToCompressor(
      Uint8List data, int width, int height, int ratio,
      {String? tag}) {
    _channel!.sink.add(_Message(data, width, height, ratio, tag));
  }

  void _handleMessageFromIsolate(dynamic data) {
    if (data is _ResultMessage) {
      _outputStreamController.sink.add(ImageResult(data.bytes, data.tag));
    }
  }

  void spinDown() {
    _isolate!.kill();
    _channel!.sink.close();
    _receivePort!.close();

    running = false;
  }
}

class _Message {
  final Uint8List bytes;
  final int width;
  final int height;
  final int ratio;
  final String? tag;

  _Message(this.bytes, this.width, this.height, this.ratio, this.tag);
}

class _ResultMessage {
  final List<int> bytes;
  final String? tag;

  _ResultMessage(this.bytes, this.tag);
}

class ImageResult {
  final List<int> bytes;
  final String? tag;

  ImageResult(this.bytes, this.tag);
}

void _compressionIsolateWorker(SendPort sendPort) async {
  final IsolateChannel channel = IsolateChannel.connectSend(sendPort);

  await for (var data in channel.stream) {
    if (data is _Message) {
      final image = Image.fromBytes(data.width, data.height, data.bytes);
      final jpg = encodeJpg(image, quality: data.ratio);

      channel.sink.add(_ResultMessage(jpg, data.tag));
    }
  }
}
