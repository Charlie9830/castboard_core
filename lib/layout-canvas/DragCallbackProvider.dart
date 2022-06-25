

import 'package:flutter/material.dart';

class DragCallbackProvider extends InheritedWidget {
  @override
  final Widget child;
  final dynamic onPointerDown;

  const DragCallbackProvider({Key? key, required this.child, this.onPointerDown }) : super(key: key, child: child);

  static DragCallbackProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DragCallbackProvider>();
  }

  @override
  bool updateShouldNotify( DragCallbackProvider oldWidget) {
    return oldWidget.onPointerDown != onPointerDown;
  }
}