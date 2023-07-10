import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:castboard_core/image_compressor/decode_result.dart';
import 'package:castboard_core/image_compressor/image_output_parameters.dart';
import 'package:castboard_core/image_compressor/image_result.dart';
import 'package:castboard_core/image_compressor/image_source_data.dart';
import 'package:image/image.dart';
import 'package:stream_channel/isolate_channel.dart';

export 'package:castboard_core/image_compressor/image_source_data.dart';
export 'package:castboard_core/image_compressor/image_output_parameters.dart';
export 'package:castboard_core/image_compressor/image_size.dart';
export 'package:castboard_core/image_compressor/image_result.dart';
export 'package:castboard_core/image_compressor/decode_result.dart';

enum ImageInterpolationType {
  nearest,
  average,
  cubic,
  linear,
}

class ImageCompressor {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  IsolateChannel? _channel;
  bool running = false;
  int _nextJobIndex = 0;
  final Map<int, Completer<ImageResult>> _imageCompressionCompleters = {};
  final Map<int, Completer<DecodeResult>> _imageDecodeCompleters = {};

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

  Future<ImageResult> dispatchSingleImageToCompressor(
      ImageSourceData sourceData, ImageOutputParameters outputParams) {
    final jobIndex = _nextJobIndex;
    _imageCompressionCompleters[jobIndex] = Completer<ImageResult>();

    dispatchImageToCompressor(sourceData, outputParams);

    return _imageCompressionCompleters[jobIndex]!.future;
  }

  void dispatchImageToCompressor(
      ImageSourceData sourceData, ImageOutputParameters outputParams) {
    _channel!.sink.add(_Message(
        jobType: _JobType.compression,
        jobIndex: _nextJobIndex++,
        bytes: sourceData.bytes,
        sourceWidth: sourceData.width,
        sourceHeight: sourceData.height,
        quality: outputParams.quality,
        targetWidth: outputParams.targetSize?.width,
        targetHeight: outputParams.targetSize?.height,
        tag: sourceData.tag,
        outputFileType: outputParams.type,
        interpolation:
            _convertImageInterpolationType(outputParams.interpolationType)));
  }

  Future<DecodeResult> decodeImage(Uint8List data) {
    final jobIndex = _nextJobIndex;
    _imageDecodeCompleters[jobIndex] = Completer<DecodeResult>();

    _channel!.sink.add(_Message(
        jobType: _JobType.decoding,
        jobIndex: _nextJobIndex++,
        sourceWidth: 0, // Not required for decoding jobs.
        sourceHeight: 0, // Not required for decoding jobs.
        bytes: data,
        quality: 100, // Not required for decoding jobs.
        interpolation: Interpolation.average // Not required for decoding jobs.
        ));

    return _imageDecodeCompleters[jobIndex]!.future;
  }

  void _handleMessageFromIsolate(dynamic data) {
    if (data is _CompressionResultMessage) {
      if (_imageCompressionCompleters.containsKey(data.jobIndex)) {
        // This Result is coming from a call of dispatchSingleImageToCompressor(). Therefore call the relevant Future completer
        // and return, not adding the result to the output stream. Adding the result erroneously to the output stream could result in a memory leak.
        // This is due to the stream buffering its entries when there are no active listeners. If we are calling dispatchSingleImageToCompressor(), we are
        // almost certainly not listening to the output stream.
        _imageCompressionCompleters[data.jobIndex]!
            .complete(ImageResult(data.bytes, data.tag));
        return;
      }

      // Add the result to the output stream.
      _outputStreamController.sink.add(ImageResult(data.bytes, data.tag));
    }

    if (data is _DecodingResultMessage) {
      if (_imageDecodeCompleters.containsKey(data.jobIndex)) {
        _imageDecodeCompleters[data.jobIndex]!.complete(DecodeResult(
          success: data.success,
          width: data.width,
          height: data.height,
          bytes: data.bytes,
        ));
      }
    }
  }

  Future<void> spinDown() async {
    _isolate!.kill();
    await _channel!.sink.close();
    _receivePort!.close();
    if (_outputStreamController.hasListener) {
      await _outputStreamController.close();
    }

    running = false;
  }
}

enum _JobType {
  compression,
  decoding,
}

class _Message {
  final _JobType jobType;
  final int jobIndex;
  final Uint8List bytes;
  final int sourceWidth;
  final int sourceHeight;
  final int quality;
  final String? tag;
  final int? targetWidth;
  final int? targetHeight;
  final Interpolation interpolation;
  final ImageType? outputFileType;

  _Message({
    required this.jobType,
    required this.jobIndex,
    required this.bytes,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.quality,
    this.targetWidth,
    this.targetHeight,
    this.tag,
    required this.interpolation,
    this.outputFileType,
  });
}

class _ResultMessageBase {
  final _JobType jobType;
  final int jobIndex;

  _ResultMessageBase(
    this.jobType,
    this.jobIndex,
  );
}

class _CompressionResultMessage extends _ResultMessageBase {
  final List<int> bytes;
  final String? tag;

  _CompressionResultMessage(
    _JobType jobType,
    int jobIndex, {
    required this.bytes,
    this.tag,
  }) : super(jobType, jobIndex);
}

class _DecodingResultMessage extends _ResultMessageBase {
  final bool success;
  final int width;
  final int height;
  final List<int> bytes;

  _DecodingResultMessage(
    _JobType jobType,
    int jobIndex, {
    required this.success,
    required this.width,
    required this.height,
    required this.bytes,
  }) : super(jobType, jobIndex);
}

void _compressionIsolateWorker(SendPort sendPort) async {
  final IsolateChannel channel = IsolateChannel.connectSend(sendPort);

  await for (var data in channel.stream) {
    if (data is _Message) {
      // Compression Job
      if (data.jobType == _JobType.compression) {
        // Instantiate an image object from the provided data.
        Image image = Image.fromBytes(
            width: data.sourceWidth,
            height: data.sourceHeight,
            bytes: ByteData.sublistView(data.bytes).buffer);

        

        // If resizing is required, perform it.
        if ((data.targetHeight != null || data.targetWidth != null) &&
            (data.targetWidth != data.sourceWidth ||
                data.targetHeight != data.sourceHeight)) {
          // Resize Image.
          image = copyResize(image,
              width: data.targetWidth,
              height: data.targetHeight,
              interpolation: data.interpolation);
        }

        // Encode the image as either a Jpg or Png.
        final encodedBytes = data.outputFileType == ImageType.jpeg
            ? encodeJpg(image, quality: data.quality)
            : encodePng(
                image,
              );

        // Send the result back to the main thread.
        channel.sink.add(_CompressionResultMessage(data.jobType, data.jobIndex,
            bytes: encodedBytes, tag: data.tag));
      }

      // Decoding Job.
      if (data.jobType == _JobType.decoding) {
        final image = decodeImage(data.bytes);

        if (image == null) {
          // Failed to decode image.
          channel.sink.add(_DecodingResultMessage(data.jobType, data.jobIndex,
              success: false, width: 0, height: 0, bytes: []));
        } else {
          // Decoding success.
          channel.sink.add(_DecodingResultMessage(data.jobType, data.jobIndex,
              success: true,
              width: image.width,
              height: image.height,
              bytes: image.getBytes()));
        }
      }
    }
  }
}

Interpolation _convertImageInterpolationType(ImageInterpolationType type) {
  switch (type) {
    case ImageInterpolationType.nearest:
      return Interpolation.nearest;
    case ImageInterpolationType.average:
      return Interpolation.average;
    case ImageInterpolationType.cubic:
      return Interpolation.cubic;
    case ImageInterpolationType.linear:
      return Interpolation.linear;
  }
}
