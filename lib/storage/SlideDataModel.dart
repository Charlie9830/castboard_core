import 'package:castboard_core/enum-converters/slideOrientationConverters.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/models/SlideModel.dart';

///
/// A Dart Domain representation of the SlideData JSON stored in Permanent Storage.
///
class SlideDataModel {
  final Map<String, SlideModel> slides;
  final String slideSizeId;
  final SlideOrientation slideOrientation;

  const SlideDataModel({
    this.slides = const <String, SlideModel>{},
    this.slideSizeId = '',
    this.slideOrientation = SlideOrientation.landscape,
  });

  Map<String, dynamic> toMap() {
    return {
      'slides': Map<String, dynamic>.fromEntries(
        slides.values.map(
          (slide) => MapEntry(
            slide.uid,
            slide.toMap(),
          ),
        ),
      ),
      'slideSizeId': slideSizeId,
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
      slideSizeId: map['slideSizeId'],
      slideOrientation: parseSlideOrientation(map['slideOrientation']),
    );
  }
}
