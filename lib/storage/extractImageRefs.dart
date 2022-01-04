import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/elements/ImageElementModel.dart';
import 'package:castboard_core/models/SlideModel.dart';

/// Extracts all the [ImageRef] objects from the [ImageElementModels] objects contained within the slide.
Iterable<ImageRef> extractImageRefs(SlideModel slide) {
  return slide.elements.values
      .where((element) => element.child is ImageElementModel)
      .map((imageElement) => (imageElement.child as ImageElementModel).ref);
}
