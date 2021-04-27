import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:flutter/material.dart';

class ContainerElement extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Axis axis;
  final List<Widget> children;

  const ContainerElement(
      {Key key,
      this.mainAxisAlignment,
      this.crossAxisAlignment,
      this.axis = Axis.horizontal,
      this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color.fromARGB(128, 128, 128, 128), child: _getChild());
  }

  Widget _getChild() {
    switch (axis) {
      case Axis.horizontal:
        return _HorizontalContainer(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        );

      case Axis.vertical:
        return _VerticalContainer(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        );

      default:
        throw Exception('Unknown Axis value. Value is $axis');
    }
  }
}

class _HorizontalContainer extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> children;

  const _HorizontalContainer(
      {Key key, this.mainAxisAlignment, this.crossAxisAlignment, this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: children ?? const [],
    );
  }
}

class _VerticalContainer extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> children;

  const _VerticalContainer(
      {Key key, this.mainAxisAlignment, this.crossAxisAlignment, this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: children ?? const [],
    );
  }
}
