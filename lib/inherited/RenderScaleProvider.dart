

import 'package:flutter/material.dart';

class RenderScale extends InheritedWidget {
  @override
  final Widget child;
  
  final double? scale;

  const RenderScale({Key? key, required this.child, this.scale = 1})
      : super(key: key, child: child);

  static RenderScale? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RenderScale>();
  }

  @override
  bool updateShouldNotify(RenderScale oldWidget) {
    return oldWidget.scale != scale;
  }
}
