import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:flutter/material.dart';

class TextElement extends StatelessWidget {
  final String text;
  final TextElementStyle style;

  const TextElement({
    Key key,
    @required this.text,
    @required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text ?? '',
        textAlign: style.alignment,
        style: TextStyle(
          color: style.color,
          fontFamily: style.fontFamily,
          fontSize: style.fontSize * RenderScale.of(context).scale,
          fontStyle: style.italics ? FontStyle.italic : FontStyle.normal,
          fontWeight: style.bold ? FontWeight.bold : FontWeight.normal,
          decoration:
              style.underline ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
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
}
