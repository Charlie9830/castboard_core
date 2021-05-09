import 'package:flutter/foundation.dart';

import 'package:castboard_core/classes/PhotoRef.dart';

class ActorModel {
  final String uid;
  final String name;
  final PhotoRef headshotRef;

  // Static
  static const String cutTrackId = 'ACTOR-TRACK-CUT';
  static const String unassignedTrackId = 'UNASSIGNED';

  ActorModel({
    @required this.uid,
    this.name = '',
    this.headshotRef = const PhotoRef.none(),
  });

  ActorModel copyWith({
    String uid,
    String name,
    PhotoRef headshotRef,
  }) {
    return ActorModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      headshotRef: headshotRef ?? this.headshotRef,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'headshotRef': headshotRef?.toMap(),
    };
  }

  factory ActorModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ActorModel(
      uid: map['uid'],
      name: map['name'],
      headshotRef: PhotoRef.fromMap(map['headshotRef']),
    );
  }
}
