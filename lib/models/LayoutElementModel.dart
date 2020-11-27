import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:flutter/material.dart';

class LayoutElementModel {
  final String uid;
  final double xPos;
  final double yPos;
  final double width;
  final double height;
  final double rotation;
  final LayoutElementChild child;

  LayoutElementModel({
    this.uid,
    this.xPos,
    this.yPos,
    this.width,
    this.height,
    this.child,
    this.rotation = 0.0,
  });

  LayoutElementModel copyWith({
    String uid,
    double xPos,
    double yPos,
    double width,
    double height,
    double rotation,
    LayoutElementChild child,
    Color color,
  }) {
    return LayoutElementModel(
      uid: uid ?? this.uid,
      xPos: xPos ?? this.xPos,
      yPos: yPos ?? this.yPos,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      child: child ?? this.child,
    );
  }
}
