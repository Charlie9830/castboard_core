import 'package:castboard_core/enum-converters/EnumConversionError.dart';
import 'package:flutter/material.dart';

TextAlign parseTextAlign(String value) {
  switch (value) {
    case 'left':
      return TextAlign.left;
    case 'right':
      return TextAlign.right;
    case 'center':
      return TextAlign.center;
    case 'center':
      return TextAlign.center;
    case 'justify':
      return TextAlign.justify;
    case 'start':
      return TextAlign.start;
    case 'end':
      return TextAlign.end;
    default:
      throw EnumConversionError(
          'Unknown value when trying to parse String into TextAlign. Unknown value is $value');
  }
}

String convertTextAlign(TextAlign textAlign) {
  switch (textAlign) {
    case TextAlign.left:
      return 'left';
    case TextAlign.right:
      return 'right';
    case TextAlign.center:
      return 'center';
    case TextAlign.justify:
      return 'justify';
    case TextAlign.start:
      return 'start';
    case TextAlign.end:
      return 'end';
    default:
      throw EnumConversionError(
          'Unknown value when trying to convert TextAlign into String. Unknown value is $textAlign');
  }
}
