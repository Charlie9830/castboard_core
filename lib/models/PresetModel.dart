import 'dart:convert';

import 'package:castboard_core/models/CastChangeModel.dart';
import 'package:castboard_core/models/ColorModel.dart';
import 'package:flutter/material.dart';

const kdefaultBuiltInPresetId = 'DEFAULT-BUILT-IN-PRESET';

final List<ColorModel> colorTags = [
  ColorModel.fromColor(Colors.black),
  ColorModel.fromColor(Colors.grey),
  ColorModel.fromColor(Colors.white),
  ColorModel.fromColor(Colors.redAccent),
  ColorModel.fromColor(Colors.blueAccent),
  ColorModel.fromColor(Colors.limeAccent),
  ColorModel.fromColor(Colors.pinkAccent),
  ColorModel.fromColor(Colors.greenAccent),
  ColorModel.fromColor(Colors.amberAccent),
  ColorModel.fromColor(Colors.indigoAccent),
  ColorModel.fromColor(Colors.orangeAccent),
  ColorModel.fromColor(Colors.purpleAccent),
  ColorModel.fromColor(Colors.yellowAccent),
];

Color? fetchPresetColorTag(int index) {
  if (index != -1 && index < colorTags.length) {
    return colorTags[index].toColor();
  }

  return null;
}

class PresetModel {
  final String uid;
  final String name;
  final String details;
  final CastChangeModel castChange;
  final bool createdOnRemote;
  final int colorTagIndex;

  // Static
  static const String unnamed = "Untitled";

  PresetModel({
    required this.uid,
    this.name = '',
    this.details = '',
    this.castChange = const CastChangeModel.initial(),
    this.createdOnRemote = false,
    this.colorTagIndex = -1,
  });

  const PresetModel.builtIn()
      : uid = kdefaultBuiltInPresetId,
        name = 'Default',
        details = '',
        castChange = const CastChangeModel.initial(),
        createdOnRemote = false,
        colorTagIndex = -1;

  PresetModel copyWith({
    String? uid,
    String? name,
    String? details,
    CastChangeModel? castChange,
    bool? createdOnRemote,
    int? colorTagIndex,
  }) {
    return PresetModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      details: details ?? this.details,
      castChange: castChange ?? this.castChange,
      createdOnRemote: createdOnRemote ?? this.createdOnRemote,
      colorTagIndex: colorTagIndex ?? this.colorTagIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'details': details,
      'castChange': castChange.toMap(),
      'createdOnRemote': createdOnRemote,
      'colorTagIndex': colorTagIndex,
    };
  }

  factory PresetModel.fromMap(Map<String, dynamic> map) {
    return PresetModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      details: map['details'] ?? '',
      castChange: CastChangeModel.fromMap(map['castChange']),
      createdOnRemote: map['createdOnRemote'] ?? false,
      colorTagIndex: map['colorTagIndex']?.toInt() ?? -1,
    );
  }

  bool get isBuiltIn => uid == kdefaultBuiltInPresetId;

  String toJson() => json.encode(toMap());

  factory PresetModel.fromJson(String source) =>
      PresetModel.fromMap(json.decode(source));
}
