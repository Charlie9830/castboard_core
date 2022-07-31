import 'package:flutter/material.dart';

typedef OnHoverChangedCallback = void Function(bool hovering);

class HoverRegion extends StatelessWidget {
  final Widget? child;
  final OnHoverChangedCallback? onHoverChanged;
  const HoverRegion({Key? key, this.child, this.onHoverChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverChanged?.call(true),
      onExit: (_) => onHoverChanged?.call(false),
      child: child,
    );
  }
}
