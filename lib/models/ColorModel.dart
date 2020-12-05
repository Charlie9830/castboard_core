import 'package:flutter/material.dart';

class ColorModel {
  final int a;
  final int r;
  final int g;
  final int b;

  ColorModel(int a, int r, int g, int b)
      : this.a = a ?? 0,
        this.r = r ?? 0,
        this.g = g ?? 0,
        this.b = b ?? 0;

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
    if (color == null) return null;

    return ColorModel(color.alpha, color.red, color.green, color.blue);
  }

  factory ColorModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ColorModel(
      map['a'],
      map['r'],
      map['g'],
      map['b'],
    );
  }
}
