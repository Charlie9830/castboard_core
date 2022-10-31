import 'package:castboard_core/layout-canvas/element_ref.dart';
import 'package:flutter/material.dart';

class ContainerItem extends StatelessWidget {
  final Widget child;
  final ElementRef id;
  final bool selected;
  final Size size;
  final int index;
  final bool deferHitTestingToChild;

  const ContainerItem({
    Key? key,
    required this.child,
    required this.id,
    required this.index,
    required this.size,
    this.selected = false,
    this.deferHitTestingToChild = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }

  ContainerItem copyWith({
    Widget? child,
    ElementRef? id,
    int? index,
    Size? size,
    bool? selected,
    bool? deferHitTestingToChild,
  }) {
    return ContainerItem(
      id: id ?? this.id,
      index: index ?? this.index,
      size: size ?? this.size,
      selected: selected ?? this.selected,
      deferHitTestingToChild:
          deferHitTestingToChild ?? this.deferHitTestingToChild,
      child: child ?? this.child,
    );
  }
}
