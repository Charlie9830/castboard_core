import 'package:castboard_core/layout-canvas/ResizeHandle.dart';
import 'package:flutter/material.dart';

typedef void OnClickCallback(int pointerId);

typedef void OnMouseUpCallback(int pointerId);

typedef void OnPositionChangeCallback(
  double xDelta,
  double yDelta,
);

class DragBox extends StatelessWidget {
  final bool selected;
  final double xPos;
  final double yPos;
  final double width;
  final double height;
  final OnClickCallback onClick;
  final OnPositionChangeCallback onPositionChange;
  final OnMouseUpCallback onMouseUp;

  const DragBox({
    Key key,
    this.width,
    this.xPos,
    this.yPos,
    this.height,
    this.onPositionChange,
    this.onClick,
    this.selected = false,
    this.onMouseUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            width: width - dragHandleWidth,
            height: height - dragHandleHeight,
            child: Listener(
              onPointerDown: (pointerEvent) {
                onClick?.call(pointerEvent.original.pointer);
              },
              onPointerMove: (pointerEvent) {
                if (pointerEvent.down) {
                  final transformedEvent =
                      pointerEvent.transformed(Matrix4.rotationZ(0));
                  onPositionChange?.call(transformedEvent.localDelta.dx,
                      transformedEvent.localDelta.dy);
                }
              },
              onPointerUp: (pointerEvent) {
                onMouseUp?.call(pointerEvent.original.pointer);
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.secondaryVariant,
                        width: 2.0,
                        style:
                            selected ? BorderStyle.solid : BorderStyle.none)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
