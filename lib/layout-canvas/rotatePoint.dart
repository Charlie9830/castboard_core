import 'dart:math';

Point rotatePoint(Point existing, double radians) {
  return Point((existing.x * cos(radians)) + (existing.y * sin(radians)),
      (existing.x * sin(radians)) + (existing.y * -1 * cos(radians)));
}

Point rotateCoords(double x, double y, double radians) {
  return rotatePoint(Point(x,y), radians);
}