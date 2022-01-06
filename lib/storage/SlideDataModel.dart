import 'package:castboard_core/enum-converters/slideOrientationConverters.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/models/SlideModel.dart';

///
/// A Dart Domain representation of the SlideData JSON stored in Permanent Storage.
///
class SlideDataModel {
  final Map<String, SlideModel> slides;
  final SlideOrientation slideOrientation;

  const SlideDataModel({
    this.slides = const <String, SlideModel>{},
    this.slideOrientation = SlideOrientation.landscape,
  });

  Map<String, dynamic> toMap() {
    return {
      'slides': Map<String?, dynamic>.fromEntries(
        slides.values.map(
          (slide) => MapEntry(
            slide.uid,
            slide.toMap(),
          ),
        ),
      ),
      'slideOrientation': convertSlideOrientation(slideOrientation),
    };
  }

  factory SlideDataModel.fromMap(Map<String, dynamic> map) {
    return SlideDataModel(
      slides: Map<String, SlideModel>.from(
        (map['slides'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            SlideModel.fromMap(value),
          ),
        ),
      ),
      slideOrientation: parseSlideOrientation(map['slideOrientation']),
    );
  }
}
