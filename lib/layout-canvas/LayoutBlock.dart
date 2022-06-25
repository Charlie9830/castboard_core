import 'package:castboard_core/layout-canvas/BlockDeltas.dart';
import 'package:castboard_core/layout-canvas/MultiChildCanvasItem.dart';
import 'package:flutter/material.dart';

class LayoutBlock extends StatelessWidget {
  final String id;
  final Widget child;
  final double xPos;
  final double yPos;
  final double width;
  final double height;
  final double rotation;
  final double debugRenderXPos;
  final double debugRenderYPos;

  const LayoutBlock({
    Key? key,
    required this.id,
    required this.child,
    this.xPos = 0,
    this.yPos = 0,
    this.width = 100,
    this.height = 100,
    this.rotation = 0,
    this.debugRenderXPos = 0,
    this.debugRenderYPos = 0,
  }) : super(key: key);

  LayoutBlock copyWith({
    Widget? child,
    double? xPos,
    double? yPos,
    double? width,
    double? height,
    double? rotation,
    double? debugRenderXPos,
    double? debugRenderYPos,
  }) {
    return LayoutBlock(
      id: id,
      xPos: xPos ?? this.xPos,
      yPos: yPos ?? this.yPos,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      debugRenderXPos: debugRenderXPos ?? this.debugRenderXPos,
      debugRenderYPos: debugRenderYPos ?? this.debugRenderYPos,
      child: child ?? this.child,
    );
  }

  LayoutBlock copyWithMultiChildUpdates({
    double? ratioX,
    double? ratioY,
  }) {
    if (child is! MultiChildCanvasItem) {
      return copyWith();
    }
    return copyWith(
        child: (child as MultiChildCanvasItem).copyWithScaledChildren(
      ratioX: ratioX ?? 1,
      ratioY: ratioY ?? 1,
    ));
  }

  LayoutBlock combinedWith({
    LayoutBlock? xComponent,
    LayoutBlock? yComponent,
  }) {
    return copyWith(
      xPos: xComponent?.xPos ?? xPos,
      yPos: yComponent?.yPos ?? yPos,
      width: xComponent?.width ?? width,
      height: yComponent?.height ?? height,
    );
  }

  BlockDelta getDeltas(LayoutBlock other) {
    return BlockDelta(
      width: width - other.width,
      height: height - other.height,
      xPos: xPos - other.xPos,
      yPos: yPos - other.yPos,
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
