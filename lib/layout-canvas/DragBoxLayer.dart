import 'package:castboard_core/elements/GroupElement.dart';
import 'package:castboard_core/layout-canvas/DragBox.dart';
import 'package:castboard_core/layout-canvas/DragHandles.dart';
import 'package:castboard_core/layout-canvas/DragSelectionBox.dart';
import 'package:castboard_core/layout-canvas/LayoutBlock.dart';
import 'package:castboard_core/layout-canvas/MultiChildCanvasItem.dart';
import 'package:castboard_core/layout-canvas/ResizeHandle.dart';
import 'package:castboard_core/layout-canvas/RotateHandle.dart';
import 'package:flutter/material.dart';

typedef void OnDragBoxClickCallback(String blockId, int pointerId);
typedef void OnDragBoxMouseUpCallback(String blockId, int pointerId);
typedef void OnResizeDoneCallback(int pointerId);
typedef void OnResizeStartCallback(
    ResizeHandleLocation handlePosition, int pointerId, String blockId);

typedef void OnRotateStartCallback(int pointerId, String blockId);

typedef void OnRotateCallback(
  double deltaX,
  double deltaY,
  String blockId,
  int pointerId,
);

typedef void OnRotateDoneCallback(
  String blockId,
  int pointerId,
);

class DragBoxLayer extends StatelessWidget {
  final bool interactive;
  final bool deferHitTestingToChildren;
  final Map<String, LayoutBlock> blocks;
  final Set<String> selectedElementIds;
  final double renderScale;
  final bool isDragSelecting;
  final double dragSelectXPos;
  final double dragSelectYPos;
  final double dragSelectWidth;
  final double dragSelectHeight;
  final dynamic onPositionChange;
  final dynamic onDragHandleDragged;
  final OnResizeDoneCallback onResizeDone;
  final OnDragBoxClickCallback onDragBoxClick;
  final OnResizeStartCallback onResizeStart;
  final OnRotateStartCallback onRotateStart;
  final OnRotateCallback onRotate;
  final OnRotateDoneCallback onRotateDone;
  final OnDragBoxMouseUpCallback onDragBoxMouseUp;

  const DragBoxLayer(
      {Key key,
      this.interactive = true,
      this.deferHitTestingToChildren = false,
      this.blocks,
      @required this.renderScale,
      this.selectedElementIds,
      this.isDragSelecting = true,
      this.dragSelectHeight = 100,
      this.dragSelectWidth = 100,
      this.dragSelectXPos = 100,
      this.dragSelectYPos = 100,
      this.onDragBoxClick,
      this.onPositionChange,
      this.onResizeDone,
      this.onDragHandleDragged,
      this.onResizeStart,
      this.onRotateStart,
      this.onRotate,
      this.onRotateDone,
      this.onDragBoxMouseUp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ..._positionBlocks(),
        //..._drawDebugIndicators(),
        if (deferHitTestingToChildren == false) ..._drawDragBoxes(),

        if (deferHitTestingToChildren == false) ..._drawDragHandles(),

        if (isDragSelecting && deferHitTestingToChildren == false)
          _drawDragSelectionBox(),
      ],
    );
  }

  Widget _drawDragSelectionBox() {
    return Positioned(
      left: dragSelectXPos,
      top: dragSelectYPos,
      width: dragSelectWidth,
      height: dragSelectHeight,
      child: DragSelectionBox(),
    );
  }

  List<Widget> _drawDragHandles() {
    return blocks.values.map((block) {
      final blockId = block.id;
      return Positioned(
        left: (block.xPos * renderScale) - dragHandleWidth / 2,
        top: ((block.yPos * renderScale) - dragHandleHeight / 2) -
            rotateHandleTotalHeight,
        width: (block.width * renderScale) + dragHandleWidth,
        height: (block.height * renderScale) +
            dragHandleHeight +
            rotateHandleTotalHeight,
        child: Transform(
          transform: Matrix4.rotationZ(block.rotation),
          origin: Offset(0, rotateHandleTotalHeight / 2),
          alignment: Alignment.center,
          child: DragHandles(
            interactive: interactive,
            selected: selectedElementIds.contains(blockId),
            height: (block.height * renderScale) + dragHandleHeight,
            width: (block.width * renderScale) + dragHandleWidth,
            onDrag: (deltaX, deltaY, position, pointerId) =>
                onDragHandleDragged(
                    deltaX, deltaY, position, pointerId, blockId),
            onDragDone: (pointerId) => onResizeDone?.call(pointerId),
            onDragStart: (handlePosition, pointerId) =>
                onResizeStart?.call(handlePosition, pointerId, blockId),
            onRotateStart: (pointerId) =>
                onRotateStart?.call(pointerId, blockId),
            onRotate: (deltaX, deltaY, pointerId) =>
                onRotate?.call(deltaX, deltaY, blockId, pointerId),
            onRotateDone: (pointerId) => onRotateDone?.call(blockId, pointerId),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _drawDebugIndicators() {
    return blocks.values.map((block) {
      // return Positioned(
      //     left: block.debugRenderXPos,
      //     top: block.debugRenderYPos,
      //     child: Container(
      //       width: 16,
      //       height: 16,
      //       decoration: BoxDecoration(
      //           border: Border.all(color: Colors.red, width: 2.0),
      //           shape: BoxShape.circle, color: Colors.purpleAccent),
      //     ));
      return Positioned(
          left: block.xPos,
          top: block.yPos,
          child: Container(
            width: block.width,
            height: block.height,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2.0)),
          ));
    }).toList();
  }

  List<Widget> _drawDragBoxes() {
    return blocks.values.map((block) {
      final blockId = block.id;
      return Positioned(
        left: (block.xPos * renderScale) - dragHandleWidth / 2,
        top: (block.yPos * renderScale) - dragHandleHeight / 2,
        width: (block.width * renderScale) + dragHandleWidth,
        height: (block.height * renderScale) + dragHandleHeight,
        child: Transform(
          transform: Matrix4.rotationZ(block.rotation),
          alignment: Alignment.center,
          child: DragBox(
            selected: selectedElementIds.contains(blockId),
            xPos: block.xPos * renderScale,
            yPos: block.yPos * renderScale,
            height: (block.height * renderScale) + dragHandleHeight,
            width: (block.width * renderScale) + dragHandleWidth,
            onPositionChange: (xPosDelta, yPosDelta) =>
                _handlePositionChange(xPosDelta, yPosDelta, blockId),
            onMouseUp: (pointerId) =>
                onDragBoxMouseUp?.call(blockId, pointerId),
            onClick: (pointerId) => onDragBoxClick?.call(blockId, pointerId),
          ),
        ),
      );
    }).toList();
  }

  void _handlePositionChange(
      double xPosDelta, double yPosDelta, String blockId) {
    onPositionChange(xPosDelta, yPosDelta, blockId);
  }

  List<Widget> _positionBlocks() {
    return blocks.values.map((block) {
      return _positionBlock(block);
    }).toList();
  }

  Positioned _positionBlock(LayoutBlock block) {
    return Positioned(
      left: block.xPos * renderScale,
      top: block.yPos * renderScale,
      width: block.width * renderScale,
      height: block.height * renderScale,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationZ(block.rotation ?? 0),
        // If Child is of type MultiChildCanvasItem, place it into it's own Stack (Thus converting the coordinate space to a local space)
        child: block.child is MultiChildCanvasItem
            ? Stack(
                children: (block.child as MultiChildCanvasItem)
                    .children
                    .map((item) => _positionBlock(item))
                    .toList())
            : block.child,
      ),
    );
  }
}
