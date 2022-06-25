

// ignore: unused_import
import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/enum-converters/EnumConversionError.dart';
import 'package:flutter/cupertino.dart';

MainAxisAlignment parseMainAxisAlignment(String value) {
  switch (value) {
    case 'start':
      return MainAxisAlignment.start;

    case 'center':
      return MainAxisAlignment.center;

    case 'end':
      return MainAxisAlignment.end;

    case 'spaceEvenly':
      return MainAxisAlignment.spaceEvenly;

    case 'spaceAround':
      return MainAxisAlignment.spaceAround;


    default:
      throw EnumConversionError(
          'Unknown value when trying to parse String into MainAxisAliggnment. Unknown value is $value');
  }
}

String convertMainAxisAlignment(MainAxisAlignment alignment) {
  switch (alignment) {
    case MainAxisAlignment.start:
      return 'start';
    case MainAxisAlignment.end:
      return 'end';
    case MainAxisAlignment.center:
      return 'center';
    case MainAxisAlignment.spaceBetween:
      return 'spaceBetween';
    case MainAxisAlignment.spaceAround:
      return 'spaceAround';
    case MainAxisAlignment.spaceEvenly:
      return 'spaceEvenly';
    default:
      throw EnumConversionError(
          'Unknown value when trying to convert MainAxisAlignment into String. Unknown value is $alignment');
  }
}
