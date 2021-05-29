import 'package:castboard_core/layout-canvas/ResizeHandle.dart';
import 'package:castboard_core/layout-canvas/RotateHandle.dart';
import 'package:flutter/material.dart';

enum ResizeHandleLocation {
  topLeft,
  topCenter,
  topRight,
  middleRight,
  bottomRight,
  bottomCenter,
  bottomLeft,
  middleLeft,
}

typedef void OnResizeHandleDragged(
    double deltaX, double deltaY, ResizeHandleLocation position, int pointerId);

typedef void OnResizeHandleDragStartCallback(
    ResizeHandleLocation handlePosition, int pointerId);

typedef void OnRotateHandleDragStartCallback(
  int pointerId,
);

typedef void OnRotateHandleDraggedCallback(
    double deltaX, double deltaY, int pointerId);

typedef void OnRotateDoneCallback(int pointerId);

class DragHandles extends StatelessWidget {
  final bool interactive;
  final bool selected;
  final double width;
  final double height;
  final OnResizeHandleDragStartCallback? onDragStart;
  final OnDragDoneCallback? onDragDone;
  final OnResizeHandleDragged? onDrag;
  final OnRotateHandleDragStartCallback? onRotateStart;
  final OnRotateHandleDraggedCallback? onRotate;
  final OnRotateDoneCallback? onRotateDone;

  const DragHandles({
    Key? key,
    this.interactive = true,
    required this.width,
    required this.height,
    this.onDrag,
    this.onDragDone,
    this.onDragStart,
    this.selected = false,
    this.onRotateStart,
    this.onRotate,
    this.onRotateDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rotator = Positioned(
        top: 0,
        left: width / 2 - rotateHandleWidth / 2,
        child: RotateHandle(
          interactive: interactive,
          selected: selected,
          onDragStart: (pointerId) => onRotateStart?.call(pointerId),
          onDrag: (deltaX, deltaY, pointerId) =>
              onRotate?.call(deltaX, deltaY, pointerId),
          onDragDone: (pointerId) => onRotateDone?.call(pointerId),
        ));

    final topLeft = Positioned(
      top: rotateHandleTotalHeight,
      left: 0,
      child: ResizeHandle(
        interactive: interactive,
        selected: selected,
        onDrag: _handleTopLeftDrag,
        onDragDone: _handleDragDone,
        onDragStart: (pointerId) =>
            _handleDragStart(ResizeHandleLocation.topLeft, pointerId),
      ),
    );

    final topCenter = Positioned(
        top: rotateHandleTotalHeight,
        left: width / 2 - dragHandleWidth / 2,
        child: ResizeHandle(
          interactive: interactive,
          selected: selected,
          onDrag: _handleTopCenterDrag,
          onDragDone: _handleDragDone,
          onDragStart: (pointerId) =>
              _handleDragStart(ResizeHandleLocation.topCenter, pointerId),
        ));

    final topRight = Positioned(
      top: rotateHandleTotalHeight,
      left: width - dragHandleWidth,
      child: ResizeHandle(
        interactive: interactive,
        selected: selected,
        onDrag: _handleTopRightDrag,
        onDragDone: _handleDragDone,
        onDragStart: (pointerId) =>
            _handleDragStart(ResizeHandleLocation.topRight, pointerId),
      ),
    );

    final middleRight = Positioned(
        top: height / 2 - dragHandleHeight / 2 + rotateHandleTotalHeight,
        left: width - dragHandleWidth,
        child: ResizeHandle(
          interactive: interactive,
          selected: selected,
          onDrag: _handleMiddleRightDrag,
          onDragDone: _handleDragDone,
          onDragStart: (pointerId) =>
              _handleDragStart(ResizeHandleLocation.middleRight, pointerId),
        ));

    final bottomRight = Positioned(
      top: height - dragHandleHeight + rotateHandleTotalHeight,
      left: width - dragHandleWidth,
      child: ResizeHandle(
        interactive: interactive,
        selected: selected,
        onDrag: _handleBottomRightDrag,
        onDragDone: _handleDragDone,
        onDragStart: (pointerId) =>
            _handleDragStart(ResizeHandleLocation.bottomRight, pointerId),
      ),
    );

    final bottomCenter = Positioned(
      top: height - dragHandleHeight + rotateHandleTotalHeight,
      left: width / 2 - dragHandleWidth / 2,
      child: ResizeHandle(
        interactive: interactive,
        selected: selected,
        onDrag: _handleBottomCenterDrag,
        onDragDone: _handleDragDone,
        onDragStart: (pointerId) =>
            _handleDragStart(ResizeHandleLocation.bottomCenter, pointerId),
      ),
    );

    final bottomLeft = Positioned(
      top: height - dragHandleHeight + rotateHandleTotalHeight,
      left: 0,
      child: ResizeHandle(
        interactive: interactive,
        selected: selected,
        onDrag: _handleBottomLeftDrag,
        onDragDone: _handleDragDone,
        onDragStart: (pointerId) =>
            _handleDragStart(ResizeHandleLocation.bottomLeft, pointerId),
      ),
    );

    final middleLeft = Positioned(
      top: height / 2 - dragHandleHeight / 2 + rotateHandleTotalHeight,
      left: 0,
      child: ResizeHandle(
        interactive: interactive,
        selected: selected,
        onDrag: _handleMiddleLeftDrag,
        onDragDone: _handleDragDone,
        onDragStart: (pointerId) =>
            _handleDragStart(ResizeHandleLocation.middleLeft, pointerId),
      ),
    );

    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          rotator,
          topLeft,
          topCenter,
          topRight,
          middleRight,
          bottomRight,
          bottomCenter,
          bottomLeft,
          middleLeft,
        ],
      ),
    );
  }

  void _handleDragStart(ResizeHandleLocation position, int pointerId) {
    onDragStart?.call(position, pointerId);
  }

  void _handleDragDone(int pointerId) {
    onDragDone?.call(pointerId);
  }

  void _handleTopLeftDrag(double deltaX, double deltaY, int pointerId) {
    onDrag?.call(deltaX, deltaY, ResizeHandleLocation.topLeft, pointerId);
  }

  void _handleTopCenterDrag(double deltaX, double deltaY, int pointerId) {
    onDrag?.call(deltaX, deltaY, ResizeHandleLocation.topCenter, pointerId);
  }

  void _handleTopRightDrag(double deltaX, double deltaY, int pointerId) {
    onDrag?.call(deltaX, deltaY, ResizeHandleLocation.topRight, pointerId);
  }

  void _handleMiddleRightDrag(double deltaX, double deltaY, int pointerId) {
    onDrag?.call(deltaX, deltaY, ResizeHandleLocation.middleRight, pointerId);
  }

  void _handleBottomRightDrag(double deltaX, double deltaY, int pointerId) {
    onDrag?.call(deltaX, deltaY, ResizeHandleLocation.bottomRight, pointerId);
  }

  void _handleBottomCenterDrag(double deltaX, double deltaY, int pointerId) {
    onDrag?.call(deltaX, deltaY, ResizeHandleLocation.bottomCenter, pointerId);
  }

  void _handleBottomLeftDrag(double deltaX, double deltaY, int pointerId) {
    onDrag?.call(deltaX, deltaY, ResizeHandleLocation.bottomLeft, pointerId);
  }

  void _handleMiddleLeftDrag(double deltaX, double deltaY, int pointerId) {
    onDrag?.call(deltaX, deltaY, ResizeHandleLocation.middleLeft, pointerId);
  }
}
