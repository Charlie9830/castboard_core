import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:flutter/material.dart';

const _alignmentMapping = <HorizontalAlignment, MainAxisAlignment>{
  HorizontalAlignment.center: MainAxisAlignment.center,
  HorizontalAlignment.left: MainAxisAlignment.start,
  HorizontalAlignment.right: MainAxisAlignment.end,
  HorizontalAlignment.spaceAround: MainAxisAlignment.spaceAround,
  HorizontalAlignment.spaceBetween: MainAxisAlignment.spaceBetween,
  HorizontalAlignment.spaceEvenly: MainAxisAlignment.spaceEvenly,
};

class ContainerElement extends StatelessWidget {
  final HorizontalAlignment alignment;
  final List<Widget> children;
  const ContainerElement({Key key, this.alignment, this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          _alignmentMapping[alignment] ?? MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children ?? const [],
    );
  }
}
