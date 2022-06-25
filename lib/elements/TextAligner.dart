import 'package:flutter/material.dart';

class TextAligner extends StatelessWidget {
  final TextAlign textAlign;
  final Widget child;
  const TextAligner({
    Key? key,
    required this.textAlign,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _getAlignment(textAlign),
      child: child,
    );
  }

  Alignment _getAlignment(TextAlign textAlign) {
    if (textAlign == TextAlign.center || textAlign == TextAlign.justify) {
      return Alignment.center;
    }

    if (textAlign == TextAlign.left || textAlign == TextAlign.start) {
      return Alignment.centerLeft;
    }

    if (textAlign == TextAlign.right || textAlign == TextAlign.end) {
      return Alignment.centerRight;
    }

    return Alignment.center;
  }
}
