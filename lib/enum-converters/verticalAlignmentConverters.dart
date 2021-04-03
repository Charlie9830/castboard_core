import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/enum-converters/EnumConversionError.dart';

VerticalAlignment parseVerticalAlignment(String value) {
  switch (value) {
    case 'top':
      return VerticalAlignment.top;

    case 'middle':
      return VerticalAlignment.middle;

    case 'bottom':
      return VerticalAlignment.bottom;

    case 'spaceEvenly':
      return VerticalAlignment.spaceEvenly;

    case 'spaceBetween':
      return VerticalAlignment.spaceBetween;

    case 'spaceAround':
      return VerticalAlignment.spaceAround;

    default:
      throw EnumConversionError(
          'Unknown value when trying to parse String into VerticalAlignment. Unknown value is $value');
  }
}

String convertVerticalAlignment(VerticalAlignment alignment) {
  switch (alignment) {
    case VerticalAlignment.top:
      return 'top';

    case VerticalAlignment.middle:
      return 'middle';

    case VerticalAlignment.bottom:
      return 'bottom';

    case VerticalAlignment.spaceAround:
      return 'spaceAround';

    case VerticalAlignment.spaceBetween:
      return 'spaceBetween';

    case VerticalAlignment.spaceEvenly:
      return 'spaceEvenly';
    default:
      throw EnumConversionError(
          'Unknown value when trying to convert VerticalAlignment into String. Unknown value is $alignment');
  }
}
