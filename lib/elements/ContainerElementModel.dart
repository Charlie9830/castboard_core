import 'package:castboard_core/enum-converters/horizontalAlignmentConverters.dart';
import 'package:castboard_core/enum-converters/verticalAlignmentConverters.dart';
import 'package:flutter/foundation.dart';

import 'package:castboard_core/classes/LayoutElementChild.dart';

enum HorizontalAlignment {
  left,
  center,
  right,
  spaceAround,
  spaceBetween,
  spaceEvenly
}

enum VerticalAlignment {
  top,
  middle,
  bottom,
  spaceAround,
  spaceBetween,
  spaceEvenly
}

class ContainerElementModel extends LayoutElementChild {
  final HorizontalAlignment horizontalAlignment;
  final VerticalAlignment verticalAlignment;
  final List<LayoutElementChild> children;

  ContainerElementModel({
    HorizontalAlignment horizontalAlignment,
    VerticalAlignment verticalAlignment,
    List<LayoutElementChild> children,
  })  : this.horizontalAlignment =
            horizontalAlignment ?? HorizontalAlignment.center,
        this.verticalAlignment = verticalAlignment ?? VerticalAlignment.middle,
        this.children = children ?? <LayoutElementChild>[],
        super(<PropertyUpdateContracts>{PropertyUpdateContracts.container});

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': 'container',
      'horizontalAlignment':
          convertHorizontalAlignment(this.horizontalAlignment),
      'verticalAlinment': convertVerticalAlignment(this.verticalAlignment),
      'children': children.map((item) => item.toMap()).toList()
    };
  }

  ContainerElementModel copyWith({
    HorizontalAlignment horizontalAlignment,
    VerticalAlignment verticalAlignment,
    List<LayoutElementChild> children,
  }) {
    return ContainerElementModel(
        horizontalAlignment: horizontalAlignment ?? this.horizontalAlignment,
        verticalAlignment: verticalAlignment ?? this.verticalAlignment,
        children: children ?? this.children);
  }
}
