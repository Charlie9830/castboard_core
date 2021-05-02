import 'package:flutter/material.dart';

class ContainerItem extends StatelessWidget {
  final Widget child;
  final String dragId;
  final Size size;
  final int index;

  const ContainerItem({
    Key key,
    @required this.child,
    @required this.dragId,
    @required this.index,
    @required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }

  ContainerItem copyWith({
    Widget child,
    String dragId,
    int index,
    Size size,
  }) {
    return ContainerItem(
      child: child ?? this.child,
      dragId: dragId ?? this.dragId,
      index: index ?? this.index,
      size: size ?? this.size,
    );
  }
}
