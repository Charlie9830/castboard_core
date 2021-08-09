import 'package:flutter/material.dart';

typedef void OnRotateCallback(double deltaX, double deltaY, int pointerId);
typedef void OnRotateDoneCallback(int pointerId);
typedef void OnRotateStartCallback(int pointerId);

const double rotateHandleWidth = 24.0;
const double rotateHandleHeight = 12.0;
const double rotateHandleTrunkHeight = 32.0;
const double rotateHandleTotalHeight =
    rotateHandleHeight + rotateHandleTrunkHeight;

class RotateHandle extends StatelessWidget {
  final bool? interactive;
  final bool selected;
  final OnRotateStartCallback? onDragStart;
  final OnRotateCallback? onDrag;
  final OnRotateDoneCallback? onDragDone;

  const RotateHandle({
    Key? key,
    this.onDrag,
    this.interactive = true,
    this.onDragStart,
    this.selected = false,
    this.onDragDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selected == false) {
      return SizedBox.fromSize(size: Size.zero);
    }

    return Container(
        width: rotateHandleWidth,
        height: rotateHandleHeight + rotateHandleTrunkHeight,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Listener(
              onPointerDown: interactive! ? _handlePointerDown : null,
              onPointerUp: interactive! ? _handlePointerUp : null,
              onPointerMove: interactive! ? _handlePointerMove : null,
              child: Icon(
                Icons.refresh_outlined,
                color: Theme.of(context).colorScheme.secondaryVariant,
              ),
            ),
            Expanded(
              child: CustomPaint(
                  painter: _Trunk(
                      color: Theme.of(context).colorScheme.secondaryVariant)),
            )
          ],
        ));
  }

  void _handlePointerDown(PointerDownEvent pointerEvent) {
    onDragStart?.call(pointerEvent.original?.pointer ?? 0);
  }

  void _handlePointerUp(PointerUpEvent pointerEvent) {
    onDragDone?.call(pointerEvent.original?.pointer ?? 0);
  }

  void _handlePointerMove(PointerMoveEvent pointerEvent) {
    if (pointerEvent.down) {
      onDrag?.call(pointerEvent.delta.dx, pointerEvent.delta.dy,
          pointerEvent.original?.pointer ?? 0);
    }
  }
}

class _Trunk extends CustomPainter {
  final Color color;

  _Trunk({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint();
    linePaint.color = color;
    linePaint.strokeWidth = 1.5;
    linePaint.strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
