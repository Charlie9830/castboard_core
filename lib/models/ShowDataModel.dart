import 'dart:convert';

import 'package:castboard_core/models/ActorIndex.dart';
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
  final Map<String, TrackRef> trackRefsByName;
  final Map<ActorRef, ActorModel> actors;
  final Map<String, PresetModel> presets;
  final List<ActorIndexBase> actorIndex;

  const ShowDataModel({
    required this.tracks,
    required this.trackRefsByName,
    required this.actors,
    required this.presets,
    required this.actorIndex,
  });

  const ShowDataModel.initial()
      : tracks = const {},
        trackRefsByName = const {},
        actors = const {},
        presets = const {},
        this.actorIndex = const <ActorIndexBase>[];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tracks': Map<dynamic, dynamic>.fromEntries(tracks.values
          .map((track) => MapEntry(track.ref.toJsonKey(), track.toMap()))),
      'trackRefsByName': Map<dynamic, dynamic>.fromEntries(trackRefsByName
          .entries
          .map((entry) => MapEntry(entry.key, entry.value.toJsonKey()))),
      'actors': Map<dynamic, dynamic>.fromEntries(actors.values
          .map((actor) => MapEntry(actor.ref.toJsonKey(), actor.toMap()))),
      'presets': Map<String?, dynamic>.fromEntries(
          presets.values.map((preset) => MapEntry(preset.uid, preset.toMap()))),
      'actorIndex': actorIndex.map((item) => item.toMap()).toList()
    };
  }

  factory ShowDataModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ShowDataModel.initial();
    }

    final rawTracksMap = map['tracks'] as Map<String, dynamic>;
    final rawTrackRefsByNameMap =
        map['trackRefsByName'] as Map<String, dynamic>;
    final rawActorsMap = map['actors'] as Map<String, dynamic>;
    final rawPresetsMap = map['presets'] as Map<String, dynamic>;
    final rawActorIndex = map['actorIndex'] == null
        ? const <Map<String, dynamic>>[]
        : map['actorIndex'] as List<dynamic>;

    return ShowDataModel(
        tracks: Map<TrackRef, TrackModel>.fromEntries(
          rawTracksMap.entries.map(
            (entry) => MapEntry(
              TrackRef.fromJsonKey(entry.key),
              TrackModel.fromMap(entry.value),
            ),
          ),
        ),
        trackRefsByName: Map<String, TrackRef>.fromEntries(
          rawTrackRefsByNameMap.entries.map(
            (entry) => MapEntry(
              entry.key,
              TrackRef.fromJsonKey(entry.value),
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
        actorIndex:
            rawActorIndex.map((map) => ActorIndexBase.fromMap(map)).toList());
  }

  ShowDataModel copyWith({
    Map<TrackRef, TrackModel>? tracks,
    Map<String, TrackRef>? trackRefsByName,
    Map<ActorRef, ActorModel>? actors,
    Map<String, PresetModel>? presets,
    List<ActorIndexBase>? actorIndex,
  }) {
    return ShowDataModel(
      tracks: tracks ?? this.tracks,
      trackRefsByName: trackRefsByName ?? this.trackRefsByName,
      actors: actors ?? this.actors,
      presets: presets ?? this.presets,
      actorIndex: actorIndex ?? this.actorIndex,
    );
  }
}
