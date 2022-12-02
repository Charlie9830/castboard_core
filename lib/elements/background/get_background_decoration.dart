import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/elements/background/get_background.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/storage/Storage.dart';
import 'package:flutter/material.dart';

BoxDecoration getBackgroundDecoration(Map<String, SlideModel> slides, String slideId) {
  final currentSlide = slides[slideId];

  if (currentSlide == null) {
    // Fallback
    return const BoxDecoration(
      color: Colors.transparent,
    );
  }

  final slideBackground = getSlideBackground(slides, currentSlide);

  return BoxDecoration(
    color: slideBackground.color,
    image: _buildDecorationImage(slideBackground.imageRef),
  );
}

DecorationImage? _buildDecorationImage(ImageRef backgroundRef) {
  if (backgroundRef == const ImageRef.none()) {
    return null;
  }

  return DecorationImage(
    alignment: Alignment.center,
    fit: BoxFit.contain,
    image: FileImage(Storage.instance.getBackgroundFile(backgroundRef)!),
  );
}
