import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/elements/TrackAssignmentInterface.dart';
import 'package:castboard_core/models/TrackRef.dart';

class HeadshotElementModel extends LayoutElementChild
    implements TrackAssignmentInterface {
  @override
  final TrackRef trackRef;

  HeadshotElementModel({
    required this.trackRef,
  }) : super(updateContracts: <PropertyUpdateContracts>{
          PropertyUpdateContracts.trackAssignment
        }, canConditionallyRender: true);

  HeadshotElementModel copyWith({
    TrackRef? trackRef,
  }) {
    return HeadshotElementModel(
      trackRef: trackRef ?? this.trackRef,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elementType': 'headshot',
      'trackRef': trackRef.toMap(),
    };
  }

  @override
  LayoutElementChild copy() {
    return copyWith();
  }
}
