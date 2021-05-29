

import 'package:castboard_core/layout-canvas/LayoutBlock.dart';
import 'package:castboard_core/layout-canvas/MultiChildCanvasItem.dart';
import 'package:flutter/material.dart';

//
// Top
//
LayoutBlock applyTopNormalUpdate(LayoutBlock existing, double deltaY) {
  final updatedElement = existing.copyWith(
    height: existing.height + _invertSign(deltaY),
    yPos: existing.yPos + deltaY,
  );
  return updatedElement;
}

LayoutBlock applyTopCrossoverUpdate(LayoutBlock existing, double deltaY) {
  final pointerPos = existing.topEdge! + deltaY;
  final difference = pointerPos - existing.bottomEdge;
  final updatedElement = existing.copyWith(
    height: difference,
    yPos: existing.bottomEdge,
  );
  return updatedElement;
}

//
// Left
//

LayoutBlock applyLeftNormalUpdate(LayoutBlock existing, double deltaX) {
  final updatedElement = existing.copyWith(
    width: existing.width + _invertSign(deltaX),
    xPos: existing.xPos + deltaX,
  );
  return updatedElement;
}

LayoutBlock applyLeftCrossoverUpdate(LayoutBlock existing, double deltaX) {
  final pointerPos = existing.leftEdge! + deltaX;
  final difference = pointerPos - existing.rightEdge;
  final updatedElement = existing.copyWith(
    width: difference,
    xPos: existing.rightEdge,
  );
  return updatedElement;
}

//
// Bottom
//
LayoutBlock applyBottomNormalUpdate(LayoutBlock existing, double deltaY) {
  final updatedElement = existing.copyWith(
    height: existing.height + deltaY,
    yPos: existing.yPos,
  );
  return updatedElement;
}

LayoutBlock applyBottomCrossoverUpdate(LayoutBlock existing, double deltaY) {
  final updatedElement = existing.copyWith(
    height: existing.topEdge! - existing.yPos + _invertSign(deltaY),
    yPos: existing.yPos + deltaY,
  );
  return updatedElement;
}

//
// Right
//
LayoutBlock applyRightNormalUpdate(LayoutBlock existing, double deltaX) {
  final updatedElement = existing.copyWith(
    width: existing.width + deltaX,
    xPos: existing.xPos,
  );
  return updatedElement;
}

LayoutBlock applyRightCrossoverUpdate(LayoutBlock existing, double deltaX) {
  final updatedElement = existing.copyWith(
    width: existing.leftEdge! - existing.xPos + _invertSign(deltaX),
    xPos: existing.xPos + deltaX,
  );
  return updatedElement;
}

//
// Helpers
//
double _invertSign(double value) {
  if (value == value.sign) {
    return value;
  }

  if (value.sign == -1.0) {
    return value.abs();
  } else {
    return 0 - value.abs();
  }
}
