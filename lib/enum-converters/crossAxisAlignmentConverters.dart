import 'package:castboard_core/enum-converters/EnumConversionError.dart';
import 'package:flutter/cupertino.dart';

CrossAxisAlignment parseCrossAxisAlignment(String value) {
  switch (value) {
    case 'start':
      return CrossAxisAlignment.start;

    case 'center':
      return CrossAxisAlignment.center;

    case 'end':
      return CrossAxisAlignment.end;

    case 'stretch':
      return CrossAxisAlignment.stretch;

    default:
      throw EnumConversionError(
          'Unknown value when trying to parse String into CrossAxisAliggnment. Unknown value is $value');
  }
}

String convertCrossAxisAlignment(CrossAxisAlignment alignment) {
  switch (alignment) {
    case CrossAxisAlignment.start:
      return 'start';
    case CrossAxisAlignment.end:
      return 'end';
    case CrossAxisAlignment.center:
      return 'center';
    case CrossAxisAlignment.stretch:
      return 'stretch';
    default:
      throw EnumConversionError(
          'Unknown value when trying to convert MainAxisAlignment into String. Unknown value is $alignment');
  }
}
