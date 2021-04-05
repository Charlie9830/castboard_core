import 'dart:ui';

import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final double gridSize;
  final double renderScale;

  GridPainter({@required this.gridSize, @required this.renderScale});

  @override
  void paint(Canvas canvas, Size size) {
    if (gridSize == 0) {
      return;
    }

    final double renderedWidth = size.width;
    final double renderedHeight = size.height;
    final double renderedGridSize = gridSize * renderScale;

    final Paint paint = Paint();
    paint.color = Colors.grey;

    final Paint centerLinePaint = Paint();
    centerLinePaint.color = Colors.grey;
    centerLinePaint.strokeWidth = 2.0;

    for (int i = 0; i < 16; i++) {
      canvas.drawLine(
        Offset(80.0 * renderScale * i, 0),
        Offset(80.0 * renderScale * i, size.height),
        paint,
      );
    }

    for (int i = 0; i < 9; i++) {
      canvas.drawLine(
        Offset(0, 80.0 * renderScale * i),
        Offset(size.width, 80.0 * renderScale * i),
        paint,
      );
    }

    // final int xLineCount = (renderedWidth / renderedGridSize).floor();

    // for (int i = 0; i <= xLineCount; i++) {
    //   canvas.drawLine(Offset(renderedGridSize * i, 0),
    //       Offset(renderedGridSize * i, renderedHeight), paint);
    // }

    // final int yLineCount = (renderedHeight / renderedGridSize).floor();

    // for (int i = 0; i <= yLineCount; i++) {
    //   canvas.drawLine(
    //     Offset(0, renderedGridSize * i),
    //     Offset(renderedWidth, renderedGridSize * i),
    //     paint,
    //   );
    // }

    // Center Line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centerLinePaint,
    );

    // Middle Line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerLinePaint,
    );
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(GridPainter oldDelegate) => false;
}
