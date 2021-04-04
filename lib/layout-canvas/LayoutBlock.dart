import 'package:castboard_core/layout-canvas/BlockDeltas.dart';
import 'package:flutter/material.dart';

class LayoutBlock extends StatelessWidget {
  final String id;
  final Widget child;
  final double xPos;
  final double yPos;
  final double desiredXPos;
  final double desiredYPos;
  final double width;
  final double height;
  final double rotation;
  final double debugRenderXPos;
  final double debugRenderYPos;

  const LayoutBlock({
    Key key,
    @required this.id,
    this.xPos,
    this.yPos,
    this.width,
    this.desiredXPos,
    this.desiredYPos,
    this.height,
    this.child,
    this.rotation,
    this.debugRenderXPos,
    this.debugRenderYPos,
  }) : super(key: key);

  LayoutBlock copyWith({
    Widget child,
    double xPos,
    double yPos,
    double width,
    double height,
    double rotation,
    double debugRenderXPos,
    double debugRenderYPos,
    double desiredXPos,
    double desiredYPos,
  }) {
    return LayoutBlock(
      id: this.id,
      xPos: xPos ?? this.xPos,
      yPos: yPos ?? this.yPos,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      child: child ?? this.child,
      desiredXPos: desiredXPos ?? this.desiredXPos,
      desiredYPos: desiredYPos ?? this.desiredYPos,
      debugRenderXPos: debugRenderXPos ?? this.debugRenderXPos,
      debugRenderYPos: debugRenderYPos ?? this.debugRenderYPos,
    );
  }

  LayoutBlock combinedWith({
    LayoutBlock xComponent,
    LayoutBlock yComponent,
  }) {
    return copyWith(
      xPos: xComponent?.xPos ?? this.xPos,
      yPos: yComponent?.yPos ?? this.yPos,
      width: xComponent?.width ?? this.width,
      height: yComponent?.height ?? this.height,
    );
  }

  BlockDelta getDeltas(LayoutBlock other) {
    return BlockDelta(
      width: this.width - other.width,
      height: this.height - other.height,
      xPos: this.xPos - other.xPos,
      yPos: this.yPos - other.yPos,
    );
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }

  double get leftEdge => xPos;
  double get rightEdge => xPos + width;
  double get topEdge => yPos;
  double get bottomEdge => yPos + height;

  Rect get rectangle {
    return Rect.fromPoints(
        Offset(xPos, yPos), Offset(xPos + width, yPos + height));
  }
}
