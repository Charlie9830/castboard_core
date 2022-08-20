import 'dart:typed_data';

import 'package:castboard_core/image_compressor/image_compressor.dart';
import 'package:castboard_core/models/SlideSizeModel.dart';
import 'package:castboard_core/storage/compress_image.dart';
import 'package:castboard_core/storage/compression_config.dart';
import 'package:castboard_core/storage/image_processing_error.dart';

Future<Uint8List> maybeCompressHeadshot(
    {required ImageCompressor compressor,
    required Uint8List sourceBytes,
    required int maxHeight}) async {
  final decodedImage = await compressor.decodeImage(sourceBytes);

  if (decodedImage.success == false) {
    await compressor.spinDown();
    throw ImageProcessingError('Image decoding returned a null image.');
  }

  if (decodedImage.height > maxHeight) {
    // Constrain a Headshot by its height and leave it at 100 percent quality.
    final outputParams = ImageOutputParameters(
      quality: CompressionConfig.instance.headshotCompressionRatio,
      targetSize:
          ImageSize(null, (const SlideSizeModel.defaultSize().height).toInt()),
    );

    return await compressImage(
      sourceBytes,
      compressor,
      decodedImage,
      outputParams,
    );
  }

  return _getUncompressedBytes(decodedImage);
}

Uint8List _getUncompressedBytes(DecodeResult decodedImage) {
  return Uint8List.fromList(decodedImage.bytes);
}
