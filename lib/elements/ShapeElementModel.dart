import 'package:castboard_core/enum-converters/shapeElementTypeConverters.dart';
import 'package:castboard_core/models/ColorModel.dart';
import 'package:flutter/material.dart';

import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/enums.dart';

class ShapeElementModel extends LayoutElementChild {
  final ShapeElementType type;
  final Color fill;
  final Color lineColor;
  final double lineWeight;

  ShapeElementModel({
    ShapeElementType? type,
    Color? fill,
    Color? lineColor,
    double? lineWeight,
  })  : this.type = type ?? ShapeElementType.square,
        this.fill = fill ?? Colors.blue,
        this.lineColor = lineColor ?? Colors.black,
        this.lineWeight = lineWeight ?? 1,
        super(updateContracts: <PropertyUpdateContracts>{
          PropertyUpdateContracts.shape
        }, canConditionallyRender: false);

  ShapeElementModel copyWith({
    ShapeElementType? type,
    Color? fill,
    Color? lineColor,
    double? lineWeight,
  }) {
    return ShapeElementModel(
      type: type ?? this.type,
      fill: fill ?? this.fill,
      lineColor: lineColor ?? this.lineColor,
      lineWeight: lineWeight ?? this.lineWeight,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elementType': 'shape',
      'type': convertShapeElementType(type),
      'fill': ColorModel.fromColor(fill).toMap(),
      'lineColor': ColorModel.fromColor(lineColor).toMap(),
      'lineWeight': lineWeight,
    };
  }

  @override
  LayoutElementChild copy() {
    return copyWith();
  }
}
