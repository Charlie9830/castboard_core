import 'package:castboard_core/image_compressor/image_size.dart';

class ImageOutputParameters {
  final ImageSize? targetSize;
  final int quality;

  ImageOutputParameters({
    this.targetSize,
    this.quality = 100,
  });
}
