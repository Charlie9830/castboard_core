import 'package:castboard_core/layout-canvas/element_ref.dart';
import 'package:castboard_core/models/ColorModel.dart';
import 'package:castboard_core/models/SlideMetadataModel.dart';
import 'package:flutter/material.dart';

import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';

class SlideModel {
  final String uid;
  final int index;
  final String name;
  final ImageRef backgroundRef;
  final String backgroundFileName;
  final Color backgroundColor;
  final bool usePreviousBackground;
  final double holdTime;
  final Map<ElementRef, LayoutElementModel> elements;

  SlideModel({
    this.uid = '',
    this.index = 0,
    this.name = '',
    this.backgroundRef = const ImageRef.none(),
    this.backgroundFileName = '',
    this.backgroundColor = Colors.white,
    this.usePreviousBackground = false,
    this.holdTime = 5,
    this.elements = const {},
  });

  SlideModel copyWith({
    String? uid,
    int? index,
    String? name,
    ImageRef? backgroundRef,
    String? backgroundFileName,
    Color? backgroundColor,
    bool? usePreviousBackground,
    double? holdTime,
    Map<ElementRef, LayoutElementModel>? elements,
  }) {
    return SlideModel(
      uid: uid ?? this.uid,
      index: index ?? this.index,
      name: name ?? this.name,
      backgroundRef: backgroundRef ?? this.backgroundRef,
      backgroundFileName: backgroundFileName ?? this.backgroundFileName,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      usePreviousBackground:
          usePreviousBackground ?? this.usePreviousBackground,
      holdTime: holdTime ?? this.holdTime,
      elements: elements ?? this.elements,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'index': index,
      'name': name,
      'backgroundRef': backgroundRef.toMap(),
      'backgroundFileName': backgroundFileName,
      'backgroundColor': ColorModel(backgroundColor.alpha, backgroundColor.red,
              backgroundColor.green, backgroundColor.blue)
          .toMap(),
      'usePreviousBackground': usePreviousBackground,
      'holdTime': holdTime,
      'elements': Map<String, dynamic>.fromEntries(elements.entries
          .map((entry) => MapEntry(entry.key.toString(), entry.value.toMap()))),
    };
  }

  factory SlideModel.fromMap(Map<String, dynamic> map) {
    return SlideModel(
      uid: map['uid'] ?? '',
      index: map['index'] ?? 0,
      name: map['name'] ?? '',
      backgroundRef: ImageRef.fromMap(map['backgroundRef']),
      backgroundFileName: map['backgroundFileName'] ?? '',
      backgroundColor: ColorModel.fromMap(map['backgroundColor']).toColor(),
      usePreviousBackground: map['usePreviousBackground'] ?? false,
      holdTime: map['holdTime'] ?? 1,
      elements: _mapElements(map['elements']),
    );
  }

  SlideMetadataModel toMetadata() {
    return SlideMetadataModel(
      slideId: uid,
      slideName: name,
      index: index,
    );
  }

  static Map<ElementRef, LayoutElementModel> _mapElements(
      Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const {};
    }

    return Map<ElementRef, LayoutElementModel>.fromEntries(map.entries.map(
        (entry) => MapEntry(ElementRef.fromString(entry.key),
            LayoutElementModel.fromMap(entry.value))));
  }
}
