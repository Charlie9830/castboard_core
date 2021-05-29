import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/storage/Storage.dart';
import 'package:flutter/material.dart';

BoxDecoration getBackground(Map<String, SlideModel> slides, String slideId) {
  final currentSlide = slides[slideId];

  if (currentSlide == null) {
    // Fallback
    return const BoxDecoration(
      color: Colors.transparent,
    );
  }

  final base = BoxDecoration(color: currentSlide.backgroundColor);

  if (currentSlide.usePreviousBackground == true && currentSlide.index >= 1) {
    // Track from a previous Slide.
    final sortedSlides = List<SlideModel>.from(slides.values)
      ..sort((a, b) => a.index - b.index)
      ..sublist(0, currentSlide.index);
    final hardValueSlide = sortedSlides.lastWhere(
        (slide) =>
            slide != currentSlide && slide.usePreviousBackground == false,
        orElse: () => SlideModel());

    return base.copyWith(
        color: hardValueSlide.backgroundColor,
        image: hardValueSlide.backgroundRef != const PhotoRef.none()
            ? _buildDecorationImage(hardValueSlide.backgroundRef)
            : null);
  }

  if (currentSlide.backgroundRef != const PhotoRef.none()) {
    // Photo
    return base.copyWith(
      image: _buildDecorationImage(currentSlide.backgroundRef),
    );
  }

  return base;
}

DecorationImage? _buildDecorationImage(PhotoRef backgroundRef) {
  if (backgroundRef == const PhotoRef.none()) {
    return null;
  }

  return DecorationImage(
    alignment: Alignment.center,
    fit: BoxFit.contain,
    image: FileImage(Storage.instance!.getBackgroundFile(backgroundRef)!),
  );
}
