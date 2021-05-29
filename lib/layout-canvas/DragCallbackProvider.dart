

import 'package:flutter/material.dart';

class DragCallbackProvider extends InheritedWidget {
  final Widget child;
  final dynamic onPointerDown;

  DragCallbackProvider({Key? key, required this.child, this.onPointerDown }) : super(key: key, child: child);

  static DragCallbackProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DragCallbackProvider>();
  }

  @override
  bool updateShouldNotify( DragCallbackProvider oldWidget) {
    return oldWidget.onPointerDown != onPointerDown;
  }
}