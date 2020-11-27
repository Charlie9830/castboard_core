import 'package:castboard_core/enums.dart';
import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:flutter/material.dart';

class ShapeElement extends StatelessWidget {
  final ShapeElementType type;
  final Color fill;
  final Color lineColor;
  final double lineWeight;

  const ShapeElement({
    Key key,
    this.type = ShapeElementType.square,
    this.fill = Colors.lightBlueAccent,
    this.lineColor = Colors.black,
    this.lineWeight = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          shape: type == ShapeElementType.square
              ? BoxShape.rectangle
              : BoxShape.circle,
          color: fill,
          border: Border.all(
            color: lineColor,
            width: lineWeight * RenderScale.of(context).scale,
          )),
    );
  }
}
