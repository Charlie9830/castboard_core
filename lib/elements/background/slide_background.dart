import 'dart:ui';

import 'package:castboard_core/classes/PhotoRef.dart';

class SlideBackground {
  final ImageRef imageRef;
  final Color color;

  SlideBackground({
    required this.imageRef,
    required this.color,
  });

  factory SlideBackground.initial() {
    return SlideBackground(
        imageRef: const ImageRef.none(),
        color: const Color.fromARGB(255, 255, 255, 255));
  }
}
