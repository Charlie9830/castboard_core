import 'package:castboard_core/elements/GroupElementModel.dart';
import 'package:castboard_core/elements/multi_child_element_model.dart';
import 'package:castboard_core/layout-canvas/element_ref.dart';
import 'package:flutter/material.dart';

import 'package:castboard_core/classes/LayoutElementChild.dart';

class LayoutElementModel {
  final ElementRef uid;
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
    required this.uid,
    required this.child,
    this.xPos = 0,
    this.yPos = 0,
    this.width = 100,
    this.height = 100,
    this.topPadding = 0,
    this.bottomPadding = 0,
    this.rightPadding = 0,
    this.leftPadding = 0,
    this.rotation = 0.0,
  });

  LayoutElementModel copyWith({
    ElementRef? uid,
    double? xPos,
    double? yPos,
    double? width,
    double? height,
    int? topPadding,
    int? rightPadding,
    int? bottomPadding,
    int? leftPadding,
    double? rotation,
    LayoutElementChild? child,
    Color? color,
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
    required double x,
    required double y,
  }) {
    return copyWith(
      xPos: xPos + x,
      yPos: yPos + y,
    );
  }

  LayoutElementModel copyWithScale({
    required double xScale,
    required double yScale,
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
      'uid': uid.toString(),
      'xPos': xPos,
      'yPos': yPos,
      'width': width,
      'height': height,
      'rotation': rotation,
      'topPadding': topPadding,
      'rightPadding': rightPadding,
      'bottomPadding': bottomPadding,
      'leftPadding': leftPadding,
      'child': child.toMap(),
    };
  }

  factory LayoutElementModel.fromMap(Map<String, dynamic> map) {
    return LayoutElementModel(
      uid: ElementRef.fromString(map['uid'] ?? ''),
      xPos: map['xPos'] ?? 0,
      yPos: map['yPos'] ?? 0,
      width: map['width'] ?? 100,
      height: map['height'] ?? 100,
      rotation: map['rotation'] ?? 0,
      topPadding: map['topPadding'] ?? 0,
      rightPadding: map['rightPadding'] ?? 0,
      bottomPadding: map['bottomPadding'] ?? 0,
      leftPadding: map['leftPadding'] ?? 0,
      child: LayoutElementChild.fromMap(map['child']),
    );
  }

  LayoutElementModel copy(ElementRef newId) {
    return copyWith(
      uid: newId,
      child: child is MultiChildElementModel
          ? child.copy(parentId: newId)
          : child.copy(),
    );
  }

  Rect get rectangle {
    return Rect.fromPoints(
        Offset(xPos, yPos), Offset(xPos + width, yPos + height));
  }

  LayoutElementModel withRemovedChild(ElementRef id) {
    if (child is MultiChildElementModel) {
      return copyWith(
          child: (child as MultiChildElementModel).withRemovedChild(id));
    }

    return this;
  }

  @override
  String toString() {
    return '''
    \n
    [LayoutElementModel]
    uid: $uid
    child-type: ${child.runtimeType},
    dimensions: $width x $height
    position: $xPos , $yPos,
    child: ${child.toString()}
    \n
    ''';
  }
}
