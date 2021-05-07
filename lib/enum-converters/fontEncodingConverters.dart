import 'package:castboard_core/enum-converters/EnumConversionError.dart';
import 'package:castboard_core/models/FontModel.dart';

FontEncoding parseFontEncoding(String value) {
  if (value == 'otf') {
    return FontEncoding.otf;
  }

  if (value == 'ttf') {
    return FontEncoding.ttf;
  }

  throw EnumConversionError(
      'Unknown value when trying to parse String into FontEncoding. Unknown value is $value');
}

String convertFontEncoding(FontEncoding value) {
  switch (value) {
    case FontEncoding.ttf:
      return 'ttf';
    case FontEncoding.otf:
      return 'otf';
    default:
      throw EnumConversionError(
          'Unknown value when trying to convert FontEncoding into String. Unknown value is $value');
  }
}
