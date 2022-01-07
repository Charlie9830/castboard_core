import 'package:castboard_core/elements/TextAligner.dart';
import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:flutter/material.dart';

class TextElement extends StatelessWidget {
  final String? text;
  final bool open;
  final TextElementStyle style;

  const TextElement({
    Key? key,
    required this.text,
    required this.style,
    this.open = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextAligner(
      textAlign: style.alignment,
      child: Text(text ?? '',
          textAlign: style.alignment,
          style: style.asTextStyle(RenderScale.of(context)!.scale!)),
    );
  }
}

class TextElementStyle {
  final TextAlign alignment;
  final Color color;
  final String fontFamily;
  final double fontSize;
  final bool bold;
  final bool italics;
  final bool underline;

  TextElementStyle({
    this.alignment = TextAlign.center,
    this.color = Colors.black,
    this.fontFamily = 'Arial',
    this.fontSize = 12,
    this.bold = false,
    this.italics = false,
    this.underline = false,
  });

  TextStyle asTextStyle(double renderScale) {
    return TextStyle(
      color: color,
      fontFamily: fontFamily,
      fontSize: fontSize * renderScale,
      fontStyle: italics ? FontStyle.italic : FontStyle.normal,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
    );
  }
}
