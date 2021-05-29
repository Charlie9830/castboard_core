import 'package:castboard_core/models/ActorRef.dart';
import 'package:flutter/foundation.dart';

import 'package:castboard_core/classes/PhotoRef.dart';

class ActorModel {
  final ActorRef ref;
  final String name;
  final PhotoRef headshotRef;

  // Static
  static const String cutTrackId = 'ACTOR-TRACK-CUT';
  static const String unassignedTrackId = 'UNASSIGNED';

  ActorModel({
    required this.ref,
    this.name = '',
    this.headshotRef = const PhotoRef.none(),
  });

  ActorModel copyWith({
    ActorRef? ref,
    String? name,
    PhotoRef? headshotRef,
  }) {
    return ActorModel(
      ref: ref ?? this.ref,
      name: name ?? this.name,
      headshotRef: headshotRef ?? this.headshotRef,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ref': ref.toMap(),
      'name': name,
      'headshotRef': headshotRef.toMap(),
    };
  }

  factory ActorModel.fromMap(Map<String, dynamic> map) {
    return ActorModel(
      ref: ActorRef.fromMap(map['ref']),
      name: map['name'] ?? '',
      headshotRef: PhotoRef.fromMap(map['headshotRef']),
    );
  }
}
