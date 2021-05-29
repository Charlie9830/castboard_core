import 'package:flutter/material.dart';

class ColorModel {
  final int a;
  final int r;
  final int g;
  final int b;

  ColorModel(this.a, this.r, this.g, this.b);

  Map<String, dynamic> toMap() {
    return {
      'a': a,
      'r': r,
      'g': g,
      'b': b,
    };
  }

  Color toColor() {
    return Color.fromARGB(a, r, g, b);
  }

  factory ColorModel.fromColor(Color color) {
    return ColorModel(color.alpha, color.red, color.green, color.blue);
  }

  factory ColorModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return ColorModel(255, 0, 0, 0);

    return ColorModel(
      map['a'] ?? 255,
      map['r'] ?? 0,
      map['g'] ?? 0,
      map['b'] ?? 0,
    );
  }
}
