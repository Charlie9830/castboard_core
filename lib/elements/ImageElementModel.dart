import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/enum-converters/shapeElementTypeConverters.dart';
import 'package:castboard_core/models/ColorModel.dart';
import 'package:flutter/material.dart';

import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/enums.dart';

class ImageElementModel extends LayoutElementChild {
  final ImageRef ref;

  ImageElementModel({
    this.ref = const ImageRef.none(),
  }) : super(
            updateContracts: <PropertyUpdateContracts>{},
            canConditionallyRender: false);

  ImageElementModel copyWith() {
    return ImageElementModel(
      ref: this.ref,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elementType': 'image',
      'ref': ref.toMap(),
    };
  }

  @override
  LayoutElementChild copy() {
    return copyWith();
  }
}
