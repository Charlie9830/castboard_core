import 'package:castboard_core/models/ActorRef.dart';

import 'package:castboard_core/classes/PhotoRef.dart';

class ActorModel {
  final ActorRef ref;
  final String name;
  final ImageRef headshotRef;
  final String category;

  // Static
  static const String cutTrackId = 'ACTOR-TRACK-CUT';
  static const String unassignedTrackId = 'UNASSIGNED';
  static const String unnamed = "Unnamed Artist";

  ActorModel({
    required this.ref,
    this.name = '',
    this.headshotRef = const ImageRef.none(),
    this.category = '',
  });

  ActorModel copyWith({
    ActorRef? ref,
    String? name,
    ImageRef? headshotRef,
    String? category,
  }) {
    return ActorModel(
      ref: ref ?? this.ref,
      name: name ?? this.name,
      headshotRef: headshotRef ?? this.headshotRef,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ref': ref.toMap(),
      'name': name,
      'headshotRef': headshotRef.toMap(),
      'category': category,
    };
  }

  factory ActorModel.fromMap(Map<String, dynamic> map) {
    return ActorModel(
      ref: ActorRef.fromMap(map['ref']),
      name: map['name'] ?? '',
      headshotRef: ImageRef.fromMap(map['headshotRef']),
      category: map['category'] ?? '',
    );
  }
}
