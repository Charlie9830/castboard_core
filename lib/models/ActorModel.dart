import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/models/ActorRef.dart';

class ActorModel {
  final ActorRef ref;
  final String name;
  final ImageRef headshotRef;
  final Map<String, String> subtitleValues;

  // Static
  static const String cutTrackId = 'ACTOR-TRACK-CUT';
  static const String unassignedTrackId = 'UNASSIGNED';
  static const String unnamed = "Unnamed Artist";

  ActorModel({
    required this.ref,
    this.name = '',
    this.headshotRef = const ImageRef.none(),
    this.subtitleValues = const {},
  });

  ActorModel copyWith({
    ActorRef? ref,
    String? name,
    ImageRef? headshotRef,
    Map<String, String>? subtitleValues,
  }) {
    return ActorModel(
      ref: ref ?? this.ref,
      name: name ?? this.name,
      headshotRef: headshotRef ?? this.headshotRef,
      subtitleValues: subtitleValues ?? this.subtitleValues,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ref': ref.toMap(),
      'name': name,
      'headshotRef': headshotRef.toMap(),
      'subtitleValues': subtitleValues,
    };
  }

  factory ActorModel.fromMap(Map<String, dynamic> map) {
    return ActorModel(
      ref: ActorRef.fromMap(map['ref']),
      name: map['name'] ?? '',
      headshotRef: ImageRef.fromMap(map['headshotRef']),
      subtitleValues: Map<String, String>.from(map['subtitleValues'] ?? {}),
    );
  }
}
