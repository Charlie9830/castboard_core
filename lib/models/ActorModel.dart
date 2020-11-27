import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:flutter/foundation.dart';

class ActorModel {
  final String uid;
  final String name;
  final PhotoRef headshotRef;

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
}
