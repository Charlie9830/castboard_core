import 'package:castboard_core/image_compressor/image_compressor.dart';
import 'package:castboard_core/image_compressor/image_size.dart';

class ImageOutputParameters {
  final ImageSize? targetSize;
  final int quality;
  final ImageInterpolationType interpolationType;

  ImageOutputParameters({
    this.targetSize,
    this.quality = 100,
    this.interpolationType = ImageInterpolationType.average,
  });
}
