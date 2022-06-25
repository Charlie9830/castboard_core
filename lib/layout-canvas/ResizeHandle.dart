import 'package:flutter/material.dart';

typedef OnDragCallback = void Function(double deltaX, double deltaY, int pointerId);
typedef OnDragDoneCallback = void Function(int pointerId);
typedef OnDragStartCallback = void Function(int pointerId);

const double dragHandleWidth = 12.0;
const double dragHandleHeight = 12.0;

class ResizeHandle extends StatelessWidget {
  final bool interactive;
  final bool selected;
  final MouseCursor cursor;
  final OnDragStartCallback? onDragStart;
  final OnDragCallback? onDrag;
  final OnDragDoneCallback? onDragDone;

  const ResizeHandle(
      {Key? key,
      this.interactive = true,
      this.cursor = MouseCursor.defer,
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
      child: MouseRegion(
        cursor: selected ? cursor : MouseCursor.defer,
        child: Container(
          width: dragHandleWidth,
          height: dragHandleHeight,
          decoration: selected
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      width: 2),
                  color: Theme.of(context).colorScheme.onBackground,
                )
              : null,
        ),
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent pointerEvent) {
    onDragStart?.call(pointerEvent.original?.pointer ?? 0);
  }

  void _handlePointerUp(PointerUpEvent pointerEvent) {
    onDragDone?.call(pointerEvent.original?.pointer ?? 0);
  }

  void _handlePointerMove(PointerMoveEvent pointerEvent) {
    if (pointerEvent.down) {
      onDrag?.call(pointerEvent.localDelta.dx, pointerEvent.localDelta.dy,
          pointerEvent.original?.pointer ?? 0);
    }
  }
}
