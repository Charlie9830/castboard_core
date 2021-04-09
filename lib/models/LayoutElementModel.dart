import 'package:flutter/material.dart';

import 'package:castboard_core/classes/LayoutElementChild.dart';

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

  LayoutElementModel copyWithOffset({
    double x,
    double y,
  }) {
    return copyWith(
      xPos: xPos - x,
      yPos: yPos - y,
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
      child: LayoutElementChild.fromMap(map['child']),
    );
  }
}
