import 'dart:ui';

import 'package:castboard_core/enums.dart';

class SlideSizeModel {
  final String uid;
  final int width;
  final int height;

  SlideSizeModel({
    required this.uid,
    this.width = 1920,
    this.height = 1080,
  });

  const SlideSizeModel.defaultSize()
      : uid = 'default',
        width = 1920,
        height = 1080;

  // Returns a new instance of SlideSize with the provided Orientation applied to the width and height dimensions.
  SlideSizeModel orientated(SlideOrientation orientation) {
    if (orientation == SlideOrientation.portrait ||
        orientation == SlideOrientation.portraitInverted) {
      return _copyWith(
        height: width,
        width: height,
      );
    } else {
      return _copyWith();
    }
  }

  Size toSize() {
    return Size(width.toDouble(), height.toDouble());
  }

  SlideSizeModel _copyWith({
    String? uid,
    int? width,
    int? height,
  }) {
    return SlideSizeModel(
      uid: uid ?? this.uid,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
