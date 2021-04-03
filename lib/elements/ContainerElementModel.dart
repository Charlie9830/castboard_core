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

enum VerticalAlignment { top, middle, bottom, spaceAround, spaceBetween, spaceEvenly }

class ContainerElementModel extends LayoutElementChild {
  final HorizontalAlignment horizontalAlignment;
  final VerticalAlignment verticalAlignment;

  ContainerElementModel({
    HorizontalAlignment horizontalAlignment,
    VerticalAlignment verticalAlignment,
  })  : this.horizontalAlignment =
            horizontalAlignment ?? HorizontalAlignment.center,
        this.verticalAlignment = verticalAlignment ?? VerticalAlignment.middle;

  @override
  Map<String, dynamic> toMap() {
    return {
      'horizontalAlignment':
          convertHorizontalAlignment(this.horizontalAlignment),
      'verticalAlinment': convertVerticalAlignment(this.verticalAlignment)
    };
  }

  ContainerElementModel copyWith({
    HorizontalAlignment horizontalAlignment,
    VerticalAlignment verticalAlignment,
  }) {
    return ContainerElementModel(
        horizontalAlignment: horizontalAlignment ?? this.horizontalAlignment,
        verticalAlignment: verticalAlignment ?? this.verticalAlignment);
  }
}
