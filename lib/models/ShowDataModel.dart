import 'package:castboard_core/models/ActorIndex.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/TrackIndex.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/models/subtitle_field_model.dart';

///
/// A Dart Domain representation of the ShowData JSON stored in Permanent Storage.
///
class ShowDataModel {
  final Map<TrackRef, TrackModel> tracks;
  final Map<String, TrackRef> trackRefsByName;
  final Map<ActorRef, ActorModel> actors;
  final Map<String, PresetModel> presets;
  final List<ActorIndexBase> actorIndex;
  final List<TrackIndexBase> trackIndex;
  final Map<String, SubtitleFieldModel> subtitleFields;

  const ShowDataModel({
    required this.tracks,
    required this.trackRefsByName,
    required this.actors,
    required this.presets,
    required this.actorIndex,
    required this.trackIndex,
    required this.subtitleFields,
  });

  const ShowDataModel.initial()
      : tracks = const {},
        trackRefsByName = const {},
        actors = const {},
        presets = const {},
        actorIndex = const <ActorIndexBase>[],
        trackIndex = const <TrackIndexBase>[],
        subtitleFields = const {};

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
      'actorIndex': actorIndex.map((item) => item.toMap()).toList(),
      'trackIndex': trackIndex.map((item) => item.toMap()).toList(),
      'subtitleFields': Map<dynamic, dynamic>.fromEntries(subtitleFields.values
          .map((subtitle) => MapEntry(subtitle.uid, subtitle.toMap()))),
    };
  }

  factory ShowDataModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const ShowDataModel.initial();
    }

    final rawTracksMap = map['tracks'] as Map<String, dynamic>;
    final rawTrackRefsByNameMap =
        map['trackRefsByName'] as Map<String, dynamic>;
    final rawActorsMap = map['actors'] as Map<String, dynamic>;
    final rawPresetsMap = map['presets'] as Map<String, dynamic>;
    final rawActorIndex = map['actorIndex'] == null
        ? const <Map<String, dynamic>>[]
        : map['actorIndex'] as List<dynamic>;
    final rawTrackIndex = map['trackIndex'] == null
        ? const <Map<String, dynamic>>[]
        : map['trackIndex'] as List<dynamic>;
    final rawSubtitleFieldsMap = map['subtitleFields'] == null
        ? const <String, dynamic>{}
        : map['subtitleFields'] as Map<String, dynamic>;

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
            rawActorIndex.map((map) => ActorIndexBase.fromMap(map)).toList(),
        trackIndex:
            rawTrackIndex.map((map) => TrackIndexBase.fromMap(map)).toList(),
        subtitleFields: Map<String, SubtitleFieldModel>.fromEntries(
            rawSubtitleFieldsMap.entries.map((entry) =>
                MapEntry(entry.key, SubtitleFieldModel.fromMap(entry.value)))));
  }

  ShowDataModel copyWith({
    Map<TrackRef, TrackModel>? tracks,
    Map<String, TrackRef>? trackRefsByName,
    Map<ActorRef, ActorModel>? actors,
    Map<String, PresetModel>? presets,
    List<ActorIndexBase>? actorIndex,
    List<TrackIndexBase>? trackIndex,
    Map<String, SubtitleFieldModel>? subtitleFields,
  }) {
    return ShowDataModel(
      tracks: tracks ?? this.tracks,
      trackRefsByName: trackRefsByName ?? this.trackRefsByName,
      actors: actors ?? this.actors,
      presets: presets ?? this.presets,
      actorIndex: actorIndex ?? this.actorIndex,
      trackIndex: trackIndex ?? this.trackIndex,
      subtitleFields: subtitleFields ?? this.subtitleFields,
    );
  }
}
