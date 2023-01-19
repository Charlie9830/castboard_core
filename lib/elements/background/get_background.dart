import 'package:castboard_core/elements/background/slide_background.dart';
import 'package:castboard_core/models/SlideModel.dart';

SlideBackground getSlideBackground(
    Map<String, SlideModel> slides, SlideModel currentSlide) {
  if (currentSlide.usePreviousBackground == true && currentSlide.index >= 1) {
    // Track from a previous Slide.
    final previousSlides = List<SlideModel>.from(slides.values)
      ..sort((a, b) => a.index - b.index)
      ..sublist(0, currentSlide.index);

    final hardValueSlide = previousSlides.lastWhere(
        (slide) =>
            slide.index < currentSlide.index &&
            slide.usePreviousBackground == false,
        orElse: () => SlideModel());

    return SlideBackground(
        imageRef: hardValueSlide.backgroundRef,
        color: hardValueSlide.backgroundColor);
  }

  return SlideBackground(
    color: currentSlide.backgroundColor,
    imageRef: currentSlide.backgroundRef,
  );
}
