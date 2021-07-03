import 'package:castboard_core/enum-converters/EnumConversionError.dart';
import 'package:castboard_core/enums.dart';

ShapeElementType parseShapeElementType(String value) {
  switch (value) {
    case 'square':
      return ShapeElementType.square;
    case 'line':
      return ShapeElementType.line;
    case 'circle':
      return ShapeElementType.circle;
    default:
      throw EnumConversionError(
          'Unknown value when trying to parse String into ShapeElementType. Unknown value is $value');
  }
}

String convertShapeElementType(ShapeElementType type) {
  switch (type) {
    case ShapeElementType.line:
      return 'line';
    case ShapeElementType.square:
      return 'square';
    case ShapeElementType.circle:
      return 'circle';
    default:
      throw EnumConversionError(
          'Unknown value when trying to convert ShapeElementType into String. Unknown value is $type');
  }
}
