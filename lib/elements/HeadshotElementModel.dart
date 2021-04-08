import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:flutter/foundation.dart';

class HeadshotElementModel extends LayoutElementChild {
  final String trackId;

  HeadshotElementModel({
    @required String trackId,
  }) : this.trackId = trackId ?? '';

  HeadshotElementModel copyWith({
    String trackId,
  }) {
    return HeadshotElementModel(
      trackId: trackId ?? this.trackId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elementType': 'headshot',
      'trackId': trackId,
    };
  }
}
