import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:flutter/material.dart';

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
}
