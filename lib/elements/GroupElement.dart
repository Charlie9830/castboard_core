import 'package:castboard_core/layout-canvas/LayoutBlock.dart';
import 'package:flutter/material.dart';

class GroupElement extends StatelessWidget {
  final List<LayoutBlock> children;
  const GroupElement({Key key, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.topLeft, children: children ?? <Widget>[]);
  }
}
