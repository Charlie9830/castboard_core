import 'dart:convert';

import 'package:castboard_core/models/ColorModel.dart';
import 'package:flutter/material.dart';

import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';

class SlideModel {
  final String uid;
  final int index;
  final String name;
  final PhotoRef backgroundRef;
  final String backgroundFileName;
  final Color backgroundColor;
  final bool usePreviousBackground;
  final double holdTime;
  final Map<String, LayoutElementModel> elements;

  SlideModel({
    this.uid = '',
    this.index = 0,
    this.name = '',
    this.backgroundRef = const PhotoRef.none(),
    this.backgroundFileName,
    this.backgroundColor = Colors.white,
    this.usePreviousBackground = false,
    this.holdTime = 1,
    this.elements = const {},
  });

  SlideModel copyWith({
    String uid,
    int index,
    String name,
    PhotoRef backgroundRef,
    String backgroundFileName,
    Color backgroundColor,
    bool usePreviousBackground,
    double holdTime,
    Map<String, LayoutElementModel> elements,
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
      'backgroundRef': backgroundRef?.toMap(),
      'backgroundFileName': backgroundFileName,
      'backgroundColor': ColorModel(backgroundColor.alpha, backgroundColor.red,
              backgroundColor.green, backgroundColor.blue)
          .toMap(),
      'usePreviousBackground': usePreviousBackground,
      'holdTime': holdTime,
      'elements': Map<String, dynamic>.fromEntries(elements.entries
          .map((entry) => MapEntry(entry.key, entry.value.toMap()))),
    };
  }

  factory SlideModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return SlideModel(
      uid: map['uid'],
      index: map['index'],
      name: map['name'],
      backgroundRef: PhotoRef.fromMap(map['backgroundRef']),
      backgroundFileName: map['backgroundFileName'],
      backgroundColor: ColorModel.fromMap(map['backgroundColor']).toColor(),
      usePreviousBackground: map['usePreviousBackground'],
      holdTime: map['holdTime'],
      elements: _mapElements(map['elements']),
    );
  }

  static Map<String, LayoutElementModel> _mapElements(
      Map<String, dynamic> map) {
    if (map == null || map.isEmpty) {
      return const {};
    }

    return Map<String, LayoutElementModel>.fromEntries(map.entries.map(
        (entry) =>
            MapEntry(entry.key, LayoutElementModel.fromMap(entry.value))));
  }
}
