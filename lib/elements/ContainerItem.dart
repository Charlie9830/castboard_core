import 'package:flutter/material.dart';

class ContainerItem extends StatelessWidget {
  final Widget child;
  final String dragId;
  final bool selected;
  final Size size;
  final int index;

  const ContainerItem({
    Key? key,
    required this.child,
    required this.dragId,
    required this.index,
    required this.size,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }

  ContainerItem copyWith({
    Widget? child,
    String? dragId,
    int? index,
    Size? size,
    bool? selected,
  }) {
    return ContainerItem(
      dragId: dragId ?? this.dragId,
      index: index ?? this.index,
      size: size ?? this.size,
      selected: selected ?? this.selected,
      child: child ?? this.child,
    );
  }
}
