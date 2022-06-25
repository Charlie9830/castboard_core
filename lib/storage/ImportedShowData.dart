import 'package:castboard_core/models/ActorIndex.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/RemoteCastChangeData.dart';
import 'package:castboard_core/models/ShowDataModel.dart';
import 'package:castboard_core/models/TrackIndex.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/storage/SlideDataModel.dart';
import 'package:castboard_core/version/fileVersion.dart';

typedef DataMigrator = ImportedShowData Function(ImportedShowData data);

class ImportedShowData {
  final ManifestModel manifest;
  final SlideDataModel slideData;
  final ShowDataModel showData;
  final PlaybackStateData? playbackState;

  ImportedShowData({
    required this.manifest,
    required this.slideData,
    required this.showData,
    required this.playbackState,
  });

  ImportedShowData ensureMigrated() {
    if (manifest.fileVersion == kMaxAllowedFileVersion) {
      return this;
    } else {
      // Chain a sequence of Migrator functions together. Each function will perform the neccassary migrations to the underlying
      // data and return an updated copy.
      final List<ImportedShowData Function(ImportedShowData data)> migrators = [
        _migrateToV2,
      ];

      // Pick the approriate range of Migrator functions, then run them in sequence, folding (reducing) the value of the data.
      return migrators
          .getRange(manifest.fileVersion - 1, kMaxAllowedFileVersion - 1)
          .fold<ImportedShowData>(
              this, (previousValue, migrator) => migrator(previousValue));
    }
  }

  ImportedShowData _copyWith({
    ManifestModel? manifest,
    SlideDataModel? slideData,
    ShowDataModel? showData,
    PlaybackStateData? playbackState,
  }) {
    return ImportedShowData(
      manifest: manifest ?? this.manifest,
      slideData: slideData ?? this.slideData,
      showData: showData ?? this.showData,
      playbackState: playbackState ?? this.playbackState,
    );
  }

  static ImportedShowData _migrateToV2(ImportedShowData data) {
    migrateActorIndex(ImportedShowData data) {
      // ActorIndex Migration.
      if (data.showData.actorIndex.length >= data.showData.actors.length) {
        // No migration required.
        return data;
      }

      /// We have to define our Map function here with an explicit [ActorIndexBase] class return value.
      /// Otherwise, Dart will implicitly return a List<ActorIndex> list. This will break code in the reducers
      /// at runtime because we will be adding/inserting elements of a List<ActorIndex> not a List<ActorIndexBase> (The base
      /// class that ActorIndex and ActorIndexDivider) derive from.
      ActorIndexBase mapper(ActorRef ref) => ActorIndex(ref);

      return data._copyWith(
          showData: data.showData.copyWith(
        actorIndex: data.showData.actors.keys.map(mapper).toList(),
      ));
    }

    migrateTrackIndex(ImportedShowData data) {
      // ActorIndex Migration.
      if (data.showData.trackIndex.length >= data.showData.tracks.length) {
        // No migration required.
        return data;
      }

      /// We have to define our Map function here with an explicit [TrackIndexBase] class return value.
      /// Otherwise, Dart will implicitly return a List<TrackIndex> list. This will break code in the reducers
      /// at runtime because we will be adding/inserting elements of a List<TrackIndex> not a List<TrackIndexBase> (The base
      /// class that TrackIndex and TrackIndexDivider) derive from.
      TrackIndexBase mapper(TrackRef ref) => TrackIndex(ref);

      return data._copyWith(
          showData: data.showData.copyWith(
        trackIndex: data.showData.tracks.keys.map(mapper).toList(),
      ));
    }

    return [migrateActorIndex, migrateTrackIndex]
        .fold(data, (previousValue, migrator) => migrator(previousValue));
  }
}
