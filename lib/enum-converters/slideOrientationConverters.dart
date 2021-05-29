

import 'package:castboard_core/enum-converters/EnumConversionError.dart';
import 'package:castboard_core/enums.dart';

SlideOrientation parseSlideOrientation(String? value) {
  switch (value) {
    case 'landscape':
      return SlideOrientation.landscape;
    case 'portrait':
      return SlideOrientation.portrait;
    case 'portraitInverted':
      return SlideOrientation.portraitInverted;
    default:
      throw EnumConversionError(
          'Unknown value when trying to parse String into PresentationOrientation. Unknown value is $value');
  }
}

String convertSlideOrientation(SlideOrientation value) {
  switch (value) {
    case SlideOrientation.landscape:
      return 'landscape';
    case SlideOrientation.portrait:
      return 'portrait';
    case SlideOrientation.portraitInverted:
      return 'portraitInverted';
    default:
      return 'landscape';
  }
}
