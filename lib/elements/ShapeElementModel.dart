import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/enums.dart';
import 'package:flutter/material.dart';

class ShapeElementModel extends LayoutElementChild {
  final ShapeElementType type;
  final Color fill;
  final Color lineColor;
  final double lineWeight;

  ShapeElementModel({
    this.type = ShapeElementType.square,
    this.fill = Colors.blueAccent,
    this.lineColor = Colors.black,
    this.lineWeight = 1.0,
  });

  ShapeElementModel copyWith({
    ShapeElementType type,
    Color fill,
    Color lineColor,
    double lineWeight,
  }) {
    return ShapeElementModel(
      type: type ?? this.type,
      fill: fill ?? this.fill,
      lineColor: lineColor ?? this.lineColor,
      lineWeight: lineWeight ?? this.lineWeight,
    );
  }
}
