import 'dart:typed_data';

import 'package:castboard_core/image_compressor/image_compressor.dart';
import 'package:castboard_core/storage/compress_image.dart';
import 'package:castboard_core/storage/image_processing_error.dart';

/// Applies scaling to the image represented by [sourceBytes] only if the image is greater then [maxHeight] or [maxWidth].
/// Otherwise only applies Jpeg Compression without rescaling.
Future<Uint8List> maybeCompressImage({
  required ImageCompressor compressor,
  required Uint8List sourceBytes,
  required int maxHeight,
  required int maxWidth,
  required int ratio,
  required ImageType outputFileType,
}) async {
  final decodedImage = await compressor.decodeImage(sourceBytes);

  if (decodedImage.success == false) {
    await compressor.spinDown();
    throw ImageProcessingError('Image decoding returned a null image.');
  }

  final imageWidth = decodedImage.width;
  final imageHeight = decodedImage.height;

  // Check if the Image is already smaller then the Maximum allowed size.
  if (imageWidth <= maxWidth && imageHeight <= maxHeight) {
    // No rescaling required. Apply "Lossless" compression.
    return await compressImage(
      sourceBytes,
      compressor,
      decodedImage,
      ImageOutputParameters(
        targetSize: ImageSize(imageWidth, imageHeight),
        quality: 100,
        type: outputFileType,
      ),
    );
  }

  ImageOutputParameters outputParams =
      _getOutputParameters(imageWidth, imageHeight, maxWidth, maxHeight, ratio);

  return await compressImage(
    sourceBytes,
    compressor,
    decodedImage,
    outputParams,
  );
}

/// Returns [ImageOutputParameters] that reflect whether the image should be scaled based on it's width or height.
ImageOutputParameters _getOutputParameters(
  int imageWidth,
  int imageHeight,
  int maxWidth,
  int maxHeight,
  int ratio,
) {
  // Determine if the Delta between the image and max dimension is greater for the Width or Height axis.
  // Then return output parameters that will compress the image based on the axis with the greater delta.
  final widthDelta = (maxWidth - imageWidth).abs();
  final heightDelta = (maxHeight - imageHeight).abs();

  ImageOutputParameters outputParams;

  if (widthDelta >= heightDelta) {
    // Compress image based on Width.
    outputParams = ImageOutputParameters(
        quality: ratio, targetSize: ImageSize(maxWidth, null));
  } else {
    outputParams = ImageOutputParameters(
        quality: ratio,
        targetSize: ImageSize(
          null,
          maxHeight,
        ));
  }
  return outputParams;
}
