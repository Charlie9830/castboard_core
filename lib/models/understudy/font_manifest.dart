import 'dart:convert';

import 'package:castboard_core/classes/BuiltInFonts.dart';
import 'package:castboard_core/models/FontModel.dart';
import 'package:castboard_core/models/understudy/font.dart';
import 'package:collection/collection.dart';

class UnderstudyFontManifest {
  final List<UnderstudyFont> fonts;

  UnderstudyFontManifest({
    required this.fonts,
  });

  factory UnderstudyFontManifest.fromList(
      {required List<String> requiredFontFamilies,
      required List<FontModel> customFonts,
      required String urlPrefix}) {
    return UnderstudyFontManifest(
        fonts: requiredFontFamilies.map((family) {
      if (BuiltInFonts.lookup(family) == true) {
        // Built in Font.
        return UnderstudyFont(
            familyName: family,
            source: Uri.encodeFull('$urlPrefix/fonts/builtin/$family'),
            isBuiltIn: true);
      } else {
        // Custom Font.
        final customFont =
            customFonts.firstWhereOrNull((item) => item.familyName == family);

        // An element may reference a custom font that isn't loaded. So be careful about
        // using it.
        if (customFont == null) {
          return UnderstudyFont(
              familyName: 'unknown',
              source: '/fonts/unknown',
              isBuiltIn: false);
        }

        return UnderstudyFont(
            familyName: family,
            source: Uri.encodeFull(
                '$urlPrefix/fonts/custom/${customFont.ref.basename}'),
            isBuiltIn: false);
      }
    }).toList());
  }

  Map<String, dynamic> toMap() {
    return {
      'fonts': fonts.map((x) => x.toMap()).toList(),
    };
  }

  factory UnderstudyFontManifest.fromMap(Map<String, dynamic> map) {
    return UnderstudyFontManifest(
      fonts: List<UnderstudyFont>.from(
          map['fonts']?.map((x) => UnderstudyFont.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory UnderstudyFontManifest.fromJson(String source) =>
      UnderstudyFontManifest.fromMap(json.decode(source));
}
