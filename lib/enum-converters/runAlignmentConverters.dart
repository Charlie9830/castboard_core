import 'package:castboard_core/enum-converters/EnumConversionError.dart';
import 'package:flutter/cupertino.dart';

WrapAlignment parseRunAlignment(String value) {
  switch (value) {
    case 'start':
      return WrapAlignment.start;

    case 'center':
      return WrapAlignment.center;

    case 'end':
      return WrapAlignment.end;

    case 'spaceAround':
      return WrapAlignment.spaceAround;

    case 'spaceEvenly':
      return WrapAlignment.spaceEvenly;

    case 'spaceBetween':
      return WrapAlignment.spaceBetween;

    default:
      throw EnumConversionError(
          'Unknown value when trying to parse String into runAlignment. Unknown value is $value');
  }
}

String convertRunAlignment(WrapAlignment alignment) {
  switch (alignment) {
    case WrapAlignment.start:
      return 'start';
    case WrapAlignment.end:
      return 'end';
    case WrapAlignment.center:
      return 'center';
    case WrapAlignment.spaceBetween:
      return 'spaceBetween';

    case WrapAlignment.spaceAround:
      return 'spaceAround';

    case WrapAlignment.spaceEvenly:
      return 'spaceEvenly';

    default:
      throw EnumConversionError(
          'Unknown value when trying to convert runAlignment into String. Unknown value is $alignment');
  }
}
