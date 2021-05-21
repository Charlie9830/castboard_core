import 'package:castboard_core/enum-converters/EnumConversionError.dart';
import 'package:castboard_core/enums.dart';

PresentationOrientation parsePresentationOrientation(String value) {
  switch (value) {
    case 'landscape':
      return PresentationOrientation.landscape;
    case 'portrait':
      return PresentationOrientation.portrait;
    case 'portraitInverted':
      return PresentationOrientation.portraitInverted;
    default:
      throw EnumConversionError(
          'Unknown value when trying to parse String into PresentationOrientation. Unknown value is $value');
  }
}

String convertPresentationOrientation(PresentationOrientation value) {
  switch (value) {
    case PresentationOrientation.landscape:
      return 'landscape';
    case PresentationOrientation.portrait:
      return 'portrait';
    case PresentationOrientation.portraitInverted:
      return 'portraitInverted';
    default:
      return 'landscape';
  }
}
