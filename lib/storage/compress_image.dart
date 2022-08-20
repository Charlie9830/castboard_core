import 'dart:typed_data';

import 'package:castboard_core/image_compressor/image_compressor.dart';

Future<Uint8List> compressImage(Uint8List bytes, ImageCompressor compressor,
    DecodeResult image, ImageOutputParameters outputParams) async {
  return Uint8List.fromList((await compressor.dispatchSingleImageToCompressor(
    ImageSourceData(
        width: image.width,
        height: image.height,
        bytes: Uint8List.fromList(image.bytes)),
    outputParams,
  ))
      .bytes);
}
