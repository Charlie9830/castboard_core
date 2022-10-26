import 'package:castboard_core/classes/PhotoRef.dart';

import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/layout-canvas/element_ref.dart';

class ImageElementModel extends LayoutElementChild {
  final ImageRef ref;

  ImageElementModel({
    this.ref = const ImageRef.none(),
  }) : super(
            updateContracts: <PropertyUpdateContracts>{},
            canConditionallyRender: false);

  ImageElementModel copyWith() {
    return ImageElementModel(
      ref: ref,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': 'image',
      'ref': ref.toMap(),
    };
  }

  @override
  LayoutElementChild copy({ElementRef? parentId}) {
    return copyWith();
  }
}
