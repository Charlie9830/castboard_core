import 'package:flutter/material.dart';

typedef void OnDragCallback(double deltaX, double deltaY, int pointerId);
typedef void OnDragDoneCallback(int pointerId);
typedef void OnDragStartCallback(int pointerId);

const double dragHandleWidth = 12.0;
const double dragHandleHeight = 12.0;

class ResizeHandle extends StatelessWidget {
  final bool interactive;
  final bool selected;
  final OnDragStartCallback onDragStart;
  final OnDragCallback onDrag;
  final OnDragDoneCallback onDragDone;

  const ResizeHandle(
      {Key key,
      this.interactive = true,
      this.onDrag,
      this.onDragStart,
      this.selected = false,
      this.onDragDone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: interactive ? _handlePointerDown : null,
      onPointerUp: interactive ? _handlePointerUp : null,
      onPointerMove: interactive ? _handlePointerMove : null,
      child: Container(
        width: dragHandleWidth,
        height: dragHandleHeight,
        decoration: selected
            ? BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: Theme.of(context).colorScheme.secondaryVariant, width: 2),
                color: Theme.of(context).colorScheme.onBackground,
              )
            : null,
      ),
    );
  }

  void _handlePointerDown(pointerEvent) {
    onDragStart?.call(pointerEvent.original.pointer);
  }

  void _handlePointerUp(pointerEvent) {
    onDragDone?.call(pointerEvent.original.pointer);
  }

  void _handlePointerMove(pointerEvent) {
    if (pointerEvent.down) {
      onDrag?.call(pointerEvent.localDelta.dx, pointerEvent.localDelta.dy,
          pointerEvent.original.pointer);
    }
  }
}
