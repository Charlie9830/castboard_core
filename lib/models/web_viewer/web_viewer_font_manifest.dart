import 'dart:convert';

import 'package:castboard_core/classes/BuiltInFonts.dart';
import 'package:castboard_core/models/FontModel.dart';
import 'package:castboard_core/models/web_viewer/web_viewer_font.dart';
import 'package:collection/collection.dart';

class WebViewerFontManifest {
  final List<WebViewerFont> fonts;

  WebViewerFontManifest({
    required this.fonts,
  });

  factory WebViewerFontManifest.fromList(
      {required List<String> requiredFontFamilies,
      required List<FontModel> customFonts,
      required String urlPrefix}) {
    return WebViewerFontManifest(
        fonts: requiredFontFamilies.map((family) {
      if (BuiltInFonts.lookup(family) == true) {
        // Built in Font.
        return WebViewerFont(
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
          return WebViewerFont(
              familyName: 'unknown',
              source: '/fonts/unknown',
              isBuiltIn: false);
        }

        return WebViewerFont(
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

  factory WebViewerFontManifest.fromMap(Map<String, dynamic> map) {
    return WebViewerFontManifest(
      fonts: List<WebViewerFont>.from(
          map['fonts']?.map((x) => WebViewerFont.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory WebViewerFontManifest.fromJson(String source) =>
      WebViewerFontManifest.fromMap(json.decode(source));
}
