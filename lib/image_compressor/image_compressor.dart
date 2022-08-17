import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:castboard_core/image_compressor/image_output_parameters.dart';
import 'package:castboard_core/image_compressor/image_result.dart';
import 'package:castboard_core/image_compressor/image_source_data.dart';
import 'package:image/image.dart';
import 'package:stream_channel/isolate_channel.dart';

export 'package:castboard_core/image_compressor/image_source_data.dart';
export 'package:castboard_core/image_compressor/image_output_parameters.dart';
export 'package:castboard_core/image_compressor/image_size.dart';
export 'package:castboard_core/image_compressor/image_result.dart';

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
      ImageSourceData sourceData, ImageOutputParameters outputParams) {
    _channel!.sink.add(_Message(
      bytes: sourceData.bytes,
      sourceWidth: sourceData.width,
      sourceHeight: sourceData.height,
      quality: outputParams.quality,
      targetWidth: outputParams.targetSize?.width,
      targetHeight: outputParams.targetSize?.height,
      tag: sourceData.tag,
    ));
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
  final int sourceWidth;
  final int sourceHeight;
  final int quality;
  final String? tag;
  final int? targetWidth;
  final int? targetHeight;

  _Message({
    required this.bytes,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.quality,
    this.targetWidth,
    this.targetHeight,
    this.tag,
  });
}

class _ResultMessage {
  final List<int> bytes;
  final String? tag;

  _ResultMessage(this.bytes, this.tag);
}

void _compressionIsolateWorker(SendPort sendPort) async {
  final IsolateChannel channel = IsolateChannel.connectSend(sendPort);

  await for (var data in channel.stream) {
    if (data is _Message) {
      // Instantiate an image object from the provided data.
      Image image =
          Image.fromBytes(data.sourceWidth, data.sourceHeight, data.bytes);

      // If resizing is required, perform it.
      if ((data.targetHeight != null || data.targetWidth != null) &&
          (data.targetWidth != data.sourceWidth ||
              data.targetHeight != data.sourceHeight)) {
        // Resize Image.
        image = copyResize(image,
            width: data.targetWidth, height: data.targetHeight);
      }

      // Encode the image as a Jpg.
      final jpg = encodeJpg(image, quality: data.quality);

      // Send the result back to the main thread.
      channel.sink.add(_ResultMessage(jpg, data.tag));
    }
  }
}
