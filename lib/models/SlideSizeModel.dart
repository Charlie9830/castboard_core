import 'dart:ui';

import 'package:castboard_core/enums.dart';

class SlideSizeModel {
  final String uid;
  final String name;
  final String details;
  final int width;
  final int height;

  SlideSizeModel({
    this.uid,
    this.name,
    this.details,
    this.width,
    this.height,
  });

  const SlideSizeModel.hd()
      : uid = 'size-hd',
        name = '720p HD',
        details = '1280 x 720',
        width = 1280,
        height = 720;

  const SlideSizeModel.fullHD()
      : uid = 'size-full-hd',
        name = '1080p Full HD',
        details = '1920 x 1080',
        width = 1920,
        height = 1080;

  const SlideSizeModel.twoK()
      : uid = 'size-2k',
        name = '2K',
        details = '2048 x 1152',
        width = 2048,
        height = 1152;

  const SlideSizeModel.fourK()
      : uid = 'size-4k',
        name = '4K UHD',
        details = '3840 x 2160',
        width = 3840,
        height = 2160;

  // Returns a new instance of SlideSize with the provided Orientation applied to the width and height dimensions.
  SlideSizeModel orientated(SlideOrientation orientation) {
    if (orientation == SlideOrientation.portrait ||
        orientation == SlideOrientation.portraitInverted) {
      return copyWith(
        height: width,
        width: height,
      );
    } else {
      return copyWith();
    }
  }

  Size toSize() {
    return Size(width.toDouble(), height.toDouble());
  }

  SlideSizeModel copyWith({
    String uid,
    String name,
    String details,
    int width,
    int height,
  }) {
    return SlideSizeModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      details: details ?? this.details,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
