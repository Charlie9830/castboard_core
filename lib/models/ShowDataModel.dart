import 'dart:convert';

import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackRef.dart';

///
/// A Dart Domain representation of the ShowData JSON stored in Permanent Storage.
///
class ShowDataModel {
  final Map<TrackRef, TrackModel> tracks;
  final Map<ActorRef, ActorModel> actors;
  final Map<String, PresetModel> presets;

  const ShowDataModel({
    this.tracks = const {},
    this.actors = const {},
    this.presets = const {},
  });

  const ShowDataModel.initial()
      : tracks = const {},
        actors = const {},
        presets = const {};

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tracks': Map<dynamic, dynamic>.fromEntries(tracks.values
          .map((track) => MapEntry(track.ref.toJsonKey(), track.toMap()))),
      'actors': Map<dynamic, dynamic>.fromEntries(actors.values
          .map((actor) => MapEntry(actor.ref.toJsonKey(), actor.toMap()))),
      'presets': Map<String?, dynamic>.fromEntries(
          presets.values.map((preset) => MapEntry(preset.uid, preset.toMap()))),
    };
  }

  factory ShowDataModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ShowDataModel.initial();
    }
    final rawTracksMap = map['tracks'] as Map<String, dynamic>;
    final rawActorsMap = map['actors'] as Map<String, dynamic>;
    final rawPresetsMap = map['presets'] as Map<String, dynamic>;

    return ShowDataModel(
      tracks: Map<TrackRef, TrackModel>.fromEntries(
        rawTracksMap.entries.map(
          (entry) => MapEntry(
            TrackRef.fromJsonKey(entry.key),
            TrackModel.fromMap(entry.value),
          ),
        ),
      ),
      actors: Map<ActorRef, ActorModel>.fromEntries(
        rawActorsMap.entries.map(
          (entry) => MapEntry(
            ActorRef.fromJsonKey(entry.key),
            ActorModel.fromMap(entry.value),
          ),
        ),
      ),
      presets: Map<String, PresetModel>.fromEntries(
        rawPresetsMap.entries.map(
          (entry) => MapEntry(
            entry.key,
            PresetModel.fromMap(entry.value),
          ),
        ),
      ),
    );
  }
}
