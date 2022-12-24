import 'dart:convert';

import 'package:castboard_core/models/understudy/font_manifest.dart';

import 'slide_model.dart';

class UnderstudySlidesPayloadModel {
  final int currentSlideIndex;
  final List<UnderstudySlideModel> slides;
  final UnderstudyFontManifest fontManifest;
  final int width;
  final int height;

  UnderstudySlidesPayloadModel({
    required this.currentSlideIndex,
    required this.slides,
    required this.fontManifest,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toMap() {
    return {
      'currentSlideIndex': currentSlideIndex,
      'slides': slides.map((x) => x.toMap()).toList(),
      'fontManifest': fontManifest.toMap(),
      'width': width,
      'height': height,
    };
  }

  factory UnderstudySlidesPayloadModel.fromMap(Map<String, dynamic> map) {
    return UnderstudySlidesPayloadModel(
      currentSlideIndex: map['currentSlideIndex']?.toInt() ?? 0,
      slides: List<UnderstudySlideModel>.from(
          map['slides']?.map((x) => UnderstudySlideModel.fromMap(x))),
      fontManifest: UnderstudyFontManifest.fromMap(map['fontManifest']),
      width: map['width'] ?? 1920,
      height: map['height'] ?? 1080,
    );
  }

  String toJson() => json.encode(toMap());

  factory UnderstudySlidesPayloadModel.fromJson(String source) =>
      UnderstudySlidesPayloadModel.fromMap(json.decode(source));
}
