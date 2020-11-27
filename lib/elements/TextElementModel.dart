import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:flutter/material.dart';

class TextElementModel extends LayoutElementChild {
  final String text;
  final String fontFamily;
  final double fontSize;
  final bool italics;
  final bool bold;
  final bool underline;
  final TextAlign alignment;
  final Color color;

  TextElementModel({
    this.text,
    this.fontFamily = 'Arial',
    this.fontSize = 24.0,
    this.italics = false,
    this.bold = false,
    this.underline = false,
    this.alignment = TextAlign.center,
    this.color = Colors.black,
  });

  TextElementModel copyWith({
    String text,
    String fontFamily,
    double fontSize,
    bool italics,
    bool bold,
    bool underline,
    TextAlign alignment,
    Color color,
  }) {
    return TextElementModel(
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      italics: italics ?? this.italics,
      bold: bold ?? this.bold,
      underline: underline ?? this.underline,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
    );
  }
}
