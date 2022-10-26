import 'package:castboard_core/layout-canvas/ResizeHandle.dart';
import 'package:castboard_core/layout-canvas/drag_box_type.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef OnClickCallback = void Function(int pointerId);

typedef OnDoubleClickCallback = void Function();

typedef OnMouseUpCallback = void Function(int pointerId);

typedef OnSecondaryMouseDownCallback = void Function(
    int pointerId, Offset position);

typedef OnPositionChangeCallback = void Function(double xDelta, double yDelta);

class DragBox extends StatelessWidget {
  final bool selected;
  final double? xPos;
  final double? yPos;
  final double? width;
  final double? height;
  final DragBoxType type;
  final OnClickCallback? onClick;
  final OnPositionChangeCallback? onPositionChange;
  final OnMouseUpCallback? onMouseUp;
  final OnDoubleClickCallback? onDoubleClick;
  final OnSecondaryMouseDownCallback? onSecondaryMouseDown;

  const DragBox({
    Key? key,
    this.type = DragBoxType.full,
    this.width,
    this.xPos,
    this.yPos,
    this.height,
    this.onPositionChange,
    this.onClick,
    this.selected = false,
    this.onMouseUp,
    this.onDoubleClick,
    this.onSecondaryMouseDown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borders = {
      DragBoxType.full: Border.all(
          color: Theme.of(context).colorScheme.secondaryContainer,
          width: 2.0,
          style: selected ? BorderStyle.solid : BorderStyle.none),
      DragBoxType.min: Border.all(
        color: Colors.grey,
        width: 1.0,
      )
    };

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          width: width! - dragHandleWidth,
          height: height! - dragHandleHeight,
          child: GestureDetector(
            onDoubleTap: () => onDoubleClick?.call(),
            child: Listener(
              onPointerDown: (pointerEvent) {
                if (pointerEvent.buttons == kSecondaryMouseButton) {
                  onSecondaryMouseDown?.call(
                      pointerEvent.original!.pointer, pointerEvent.position);
                } else {
                  onClick?.call(pointerEvent.original!.pointer);
                }
              },
              onPointerMove: (pointerEvent) {
                if (pointerEvent.down) {
                  final transformedEvent =
                      pointerEvent.transformed(Matrix4.rotationZ(0));
                  onPositionChange?.call(
                    transformedEvent.localDelta.dx,
                    transformedEvent.localDelta.dy,
                  );
                }
              },
              onPointerUp: (pointerEvent) {
                onMouseUp?.call(pointerEvent.original!.pointer);
              },
              child: Container(
                decoration: BoxDecoration(border: borders[type]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
