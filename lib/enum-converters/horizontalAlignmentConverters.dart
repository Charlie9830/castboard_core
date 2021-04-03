import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/enum-converters/EnumConversionError.dart';

HorizontalAlignment parseHorizontalAlignment(String value) {
  switch (value) {
    case 'left':
      return HorizontalAlignment.left;

    case 'center':
      return HorizontalAlignment.center;

    case 'right':
      return HorizontalAlignment.right;

    case 'spaceBetween':
      return HorizontalAlignment.spaceEvenly;

    case 'spaceAround':
      return HorizontalAlignment.spaceAround;

    case 'spaceEvenly':
      return HorizontalAlignment.spaceEvenly;

    default:
      throw EnumConversionError(
          'Unknown value when trying to parse String into HorizontalAlignment. Unknown value is $value');
  }
}

String convertHorizontalAlignment(HorizontalAlignment alignment) {
  switch (alignment) {
    case HorizontalAlignment.left:
      return 'left';

    case HorizontalAlignment.center:
      return 'center';

    case HorizontalAlignment.right:
      return 'right';

    case HorizontalAlignment.spaceBetween:
      return 'spaceBetween';

    case HorizontalAlignment.spaceEvenly:
      return 'spaceEvenly';

    case HorizontalAlignment.spaceAround:
      return 'spaceAround';
    default:
      throw EnumConversionError(
          'Unknown value when trying to convert HorizontalAlignment into String. Unknown value is $alignment');
  }
}
