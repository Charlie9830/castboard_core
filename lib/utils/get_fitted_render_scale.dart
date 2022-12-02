import 'dart:ui';

/// Calculates a render scale that Fits the content into the available window size.
double getFittedRenderScale(Size windowSize, Size desiredSlideSize) {
  final xRatio = windowSize.width / desiredSlideSize.width;
  final yRatio = windowSize.height / desiredSlideSize.height;

  return xRatio < yRatio ? xRatio : yRatio;
}
