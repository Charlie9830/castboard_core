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

    final int xLineCount = (renderedWidth / renderedGridSize).floor();

    for (int i = 0; i <= xLineCount; i++) {
      canvas.drawLine(Offset(renderedGridSize * i, 0),
          Offset(renderedGridSize * i, renderedHeight), paint);
    }

    final int yLineCount = (renderedHeight / renderedGridSize).floor();

    for (int i = 0; i <= yLineCount; i++) {
      canvas.drawLine(
        Offset(0, renderedGridSize * i),
        Offset(renderedWidth, renderedGridSize * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(GridPainter oldDelegate) => false;
}
