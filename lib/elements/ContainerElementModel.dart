import 'package:castboard_core/enum-converters/axisConverters.dart';

import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/enum-converters/crossAxisAlignmentConverters.dart';
import 'package:castboard_core/enum-converters/mainAxisAlignmentConverters.dart';
import 'package:flutter/widgets.dart';

class ContainerElementModel extends LayoutElementChild {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Axis axis;
  final List<LayoutElementChild> children;

  ContainerElementModel({
    MainAxisAlignment mainAxisAlignment,
    CrossAxisAlignment crossAxisAlignment,
    List<LayoutElementChild> children,
    Axis axis,
  })  : this.children = children ?? <LayoutElementChild>[],
        this.mainAxisAlignment = mainAxisAlignment ?? MainAxisAlignment.center,
        this.crossAxisAlignment =
            crossAxisAlignment ?? CrossAxisAlignment.center,
        this.axis = axis ?? Axis.horizontal,
        super(<PropertyUpdateContracts>{PropertyUpdateContracts.container});

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': 'container',
      'axis': convertAxis(this.axis),
      'mainAxisAlignment': convertMainAxisAlignment(this.mainAxisAlignment),
      'crossAxisAlignment': convertCrossAxisAlignment(this.crossAxisAlignment),
      'children': children.map((item) => item.toMap()).toList()
    };
  }

  ContainerElementModel copyWith({
    Axis axis,
    MainAxisAlignment mainAxisAlignment,
    CrossAxisAlignment crossAxisAlignment,
    List<LayoutElementChild> children,
  }) {
    return ContainerElementModel(
        mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
        axis: axis ?? this.axis,
        children: children ?? this.children);
  }
}
