import 'package:flutter/material.dart';

import 'package:castboard_core/classes/LayoutElementChild.dart';

class LayoutElementModel {
  final String uid;
  final double xPos;
  final double yPos;
  final double width;
  final double height;
  final double rotation;
  final int topPadding;
  final int rightPadding;
  final int leftPadding;
  final int bottomPadding;
  final LayoutElementChild child;

  LayoutElementModel({
    this.uid,
    this.xPos,
    this.yPos,
    this.width,
    this.height,
    this.topPadding,
    this.bottomPadding,
    this.rightPadding,
    this.leftPadding,
    this.child,
    this.rotation = 0.0,
  });

  LayoutElementModel copyWith({
    String uid,
    double xPos,
    double yPos,
    double width,
    double height,
    int topPadding,
    int rightPadding,
    int bottomPadding,
    int leftPadding,
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
      topPadding: topPadding ?? this.topPadding,
      rightPadding: rightPadding ?? this.rightPadding,
      bottomPadding: bottomPadding ?? this.bottomPadding,
      leftPadding: leftPadding ?? this.leftPadding,
      child: child ?? this.child,
    );
  }

  LayoutElementModel copyWithOffset({
    double x,
    double y,
  }) {
    return copyWith(
      xPos: xPos - x,
      yPos: yPos - y,
    );
  }

  LayoutElementModel copyWithScale({
    double xScale,
    double yScale,
  }) {
    return copyWith(
      width: width * xScale,
      xPos: xPos * xScale,
      height: height * yScale,
      yPos: yPos * yScale,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'xPos': xPos,
      'yPos': yPos,
      'width': width,
      'height': height,
      'rotation': rotation,
      'topPadding': topPadding,
      'rightPadding': rightPadding,
      'bottomPadding': bottomPadding,
      'leftPadding': leftPadding,
      'child': child?.toMap(),
    };
  }

  factory LayoutElementModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return LayoutElementModel(
      uid: map['uid'],
      xPos: map['xPos'],
      yPos: map['yPos'],
      width: map['width'],
      height: map['height'],
      rotation: map['rotation'],
      topPadding: map['topPadding'],
      rightPadding: map['rightPadding'],
      bottomPadding: map['bottomPadding'],
      leftPadding: map['leftPadding'],
      child: LayoutElementChild.fromMap(map['child']),
    );
  }
}
