import 'dart:convert';

import 'package:castboard_core/models/understudy/web_viewer_font_manifest.dart';

import 'html_slide_model.dart';

class SlidesPayloadModel {
  final int currentSlideIndex;
  final List<HTMLSlideModel> slides;
  final WebViewerFontManifest fontManifest;

  SlidesPayloadModel({
    required this.currentSlideIndex,
    required this.slides,
    required this.fontManifest,
  });

  Map<String, dynamic> toMap() {
    return {
      'currentSlideIndex': currentSlideIndex,
      'slides': slides.map((x) => x.toMap()).toList(),
      'fontManifest': fontManifest.toMap(),
    };
  }

  factory SlidesPayloadModel.fromMap(Map<String, dynamic> map) {
    return SlidesPayloadModel(
      currentSlideIndex: map['currentSlideIndex']?.toInt() ?? 0,
      slides: List<HTMLSlideModel>.from(
          map['slides']?.map((x) => HTMLSlideModel.fromMap(x))),
      fontManifest: WebViewerFontManifest.fromMap(map['fontManifest']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SlidesPayloadModel.fromJson(String source) =>
      SlidesPayloadModel.fromMap(json.decode(source));
}
