
import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final double gridSize;
  final double renderScale;
  final int gridLineDrawRatio;

  GridPainter({
    required this.gridSize,
    required this.renderScale,
    this.gridLineDrawRatio = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (gridSize == 0) {
      return;
    }

    final renderedGridSize = gridSize * renderScale;

    final Paint gridLinePaint = Paint();
    gridLinePaint.color = Colors.grey.withAlpha(128);

    final Paint centerLinePaint = Paint();
    centerLinePaint.color = Colors.grey.withAlpha(128);
    centerLinePaint.strokeWidth = 2.0;

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

    // Draw Grid Lines.
    final double gridLineGap = renderedGridSize *
        gridLineDrawRatio; // It's optically overwhelming to draw every single line
    // so we only draw every gridLineDrawRatio'th line.

    // Vertical gridLines.
    final double center = size.width / 2;
    double currentLeft = center - gridLineGap;
    double currentRight = center + gridLineGap;

    while (currentLeft >= 0 && currentRight <= size.width) {
      canvas.drawLine(
        Offset(currentLeft, 0),
        Offset(currentLeft, size.height),
        gridLinePaint,
      );

      canvas.drawLine(
        Offset(currentRight, 0),
        Offset(currentRight, size.height),
        gridLinePaint,
      );

      currentLeft -= gridLineGap;
      currentRight += gridLineGap;
    }

    // Horizontal GridLines
    final double middle = size.height / 2;
    double currentTop = middle - gridLineGap;
    double currentBottom = middle + gridLineGap;

    while (currentTop >= 0 && currentBottom <= size.height) {
      canvas.drawLine(
        Offset(0, currentTop),
        Offset(size.width, currentTop),
        gridLinePaint,
      );

      canvas.drawLine(
        Offset(0, currentBottom),
        Offset(size.width, currentBottom),
        gridLinePaint,
      );

      currentTop -= gridLineGap;
      currentBottom += gridLineGap;
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(GridPainter oldDelegate) => false;
}
