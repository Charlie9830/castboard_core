import 'dart:convert';

import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/TrackRef.dart';

class CastChangeModel {
  final Map<TrackRef, ActorRef> assignments;

  CastChangeModel(Map<TrackRef, ActorRef> assignments)
      : this.assignments = assignments ?? const <TrackRef, ActorRef>{};

  const CastChangeModel.initial() : assignments = const <TrackRef, ActorRef>{};

  CastChangeModel _copyWith({Map<TrackRef, ActorRef> assignments}) {
    return CastChangeModel(
      assignments ?? this.assignments,
    );
  }

  bool hasAssignment(TrackRef track) {
    return assignments.containsKey(track);
  }

  ActorRef actorAt(TrackRef track) {
    return assignments[track];
  }

  CastChangeModel withUpdatedAssignment(TrackRef track, ActorRef actor) {
    if (track == null || actor == null) {
      throw ('track and actor must not be null. Value provided for track is $track and value provided for actor is $actor');
    }

    return _copyWith(
        assignments: Map<TrackRef, ActorRef>.from(assignments)
          ..addAll({track: actor}));
  }

  CastChangeModel combinedWithOther(CastChangeModel other) {
    if (other == null) {
      throw ('CastChangeModel other cannot be null');
    }

    return _copyWith(
      assignments: Map<TrackRef, ActorRef>.from(assignments)
        ..addAll(
          Map<TrackRef, ActorRef>.from(other.assignments)
            ..removeWhere((track, actor) => actor.isUnassigned),
        ),
    );
  }

  CastChangeModel combinedWithOthers(Iterable<CastChangeModel> others) {
    if (others == null || others.isEmpty) {
      return _copyWith();
    }

    return others.reduce((accum, other) => accum.combinedWithOther(other));
  }

  Map<K2, V2> map<K2, V2>(
      MapEntry<K2, V2> Function(TrackRef, ActorRef) convert) {
    return assignments.map(convert);
  }

  Map<String, dynamic> toMap() {
    return {
      'assignments':
          assignments.map((key, value) => MapEntry(key.toMap(), value.toMap())),
    };
  }

  bool isUnassigned(TrackRef track) {
    return assignments[track]?.isUnassigned ?? false;
  }

  bool isCut(TrackRef track) {
    return assignments[track]?.isCut ?? false;
  }

  factory CastChangeModel.fromMap(Map<String, dynamic> map) {
    return CastChangeModel(
      Map<TrackRef, ActorRef>.from(
        (map['assignments'] as Map<dynamic, dynamic>).map(
          (key, value) => MapEntry(
            TrackRef.fromMap(key),
            ActorRef.fromMap(value),
          ),
        ),
      ),
    );
  }
}
