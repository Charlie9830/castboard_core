import 'package:castboard_core/image_compressor/image_compressor.dart';

enum ImageType {
  jpeg,
  png,
}

class ImageOutputParameters {
  final ImageSize? targetSize;
  final int quality;
  final ImageInterpolationType interpolationType;
  final ImageType type;

  ImageOutputParameters({
    this.targetSize,
    this.quality = 100,
    this.interpolationType = ImageInterpolationType.average,
    this.type = ImageType.jpeg,
  });

  /// Returns an [ImageType] based of the value of [ext]. Falls back to [ImageType.jpg].
  static ImageType determineImageType(String ext) {
    final lowered = ext.toLowerCase().trim();

    switch (lowered) {
      case '.png':
        return ImageType.png;
      case '.jpg':
        return ImageType.jpeg;
      case '.jpeg':
        return ImageType.jpeg;
      default:
        return ImageType.jpeg;
    }
  }
}
