import 'package:castboard_core/enum-converters/EnumConversionError.dart';
import 'package:castboard_core/image_compressor/image_compressor.dart';

ImageInterpolationType parseImageInterpolationType(String value) {
  switch (value) {
    case 'nearest':
      return ImageInterpolationType.nearest;
    case 'average':
      return ImageInterpolationType.average;
    default:
      throw EnumConversionError(
          'Unknown value when trying to parse String into ImageInterpolationType. Unknown value is $value');
  }
}

String convertImageInterpolationType(ImageInterpolationType value) {
  switch (value) {
    case ImageInterpolationType.nearest:
      return 'nearest';
    case ImageInterpolationType.average:
      return 'average';
    default:
      return 'average';
  }
}
