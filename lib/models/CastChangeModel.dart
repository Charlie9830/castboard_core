import 'dart:convert';

import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/TrackRef.dart';

class CastChangeModel {
  final Map<TrackRef, ActorRef> assignments;

  CastChangeModel(this.assignments);

  const CastChangeModel.initial() : assignments = const <TrackRef, ActorRef>{};

  CastChangeModel _copyWith({Map<TrackRef, ActorRef>? assignments}) {
    return CastChangeModel(
      assignments ?? this.assignments,
    );
  }

  bool hasAssignment(TrackRef track) {
    return assignments.containsKey(track);
  }

  ActorRef? actorAt(TrackRef track) {
    return assignments[track];
  }

  CastChangeModel withRemovedAssignment(TrackRef track) {
    return _copyWith(
      assignments: Map<TrackRef, ActorRef>.from(assignments)..remove(track),
    );
  }

  CastChangeModel withUpdatedAssignment(TrackRef track, ActorRef actor) {
    return _copyWith(
        assignments: Map<TrackRef, ActorRef>.from(assignments)
          ..addAll({track: actor}));
  }

  CastChangeModel combinedWithOther(CastChangeModel other) {
    return _copyWith(
      assignments: Map<TrackRef, ActorRef>.from(assignments)
        ..addAll(
          Map<TrackRef, ActorRef>.from(other.assignments)
            ..removeWhere((track, actor) => actor.isUnassigned),
        ),
    );
  }

  CastChangeModel combinedWithOthers(Iterable<CastChangeModel> others) {
    if (others.isEmpty) {
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
      'assignments': assignments
          .map((key, value) => MapEntry(key.toJsonKey(), value.toJsonKey())),
    };
  }

  bool isUnassigned(TrackRef track) {
    return assignments[track]?.isUnassigned ?? false;
  }

  bool isCut(TrackRef track) {
    return assignments[track]?.isCut ?? false;
  }

  factory CastChangeModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return CastChangeModel.initial();
    }

    return CastChangeModel(
      Map<TrackRef, ActorRef>.from(
        (map['assignments'] as Map<String, dynamic>).map(
          (trackKey, actorKey) => MapEntry(
            TrackRef.fromJsonKey(trackKey),
            ActorRef.fromJsonKey(actorKey),
          ),
        ),
      ),
    );
  }
}
