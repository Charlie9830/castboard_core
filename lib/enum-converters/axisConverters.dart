

import 'package:castboard_core/enum-converters/EnumConversionError.dart';
import 'package:flutter/widgets.dart';

Axis parseAxis(String value) {
  switch (value) {
    case 'horizontal':
      return Axis.horizontal;
    case 'vertical':
      return Axis.vertical;
    default:
      throw EnumConversionError(
          'Unknown value when trying to parse String into Axis. Unknown value is $value');
  }
}

String convertAxis(Axis value) {
  switch (value) {
    case Axis.horizontal:
      return 'horizontal';
    case Axis.vertical:
      return 'vertical';
    default:
      return 'horizontal';
  }
}
