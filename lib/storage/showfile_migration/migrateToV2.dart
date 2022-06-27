import 'package:castboard_core/models/ActorIndex.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/TrackIndex.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/storage/ImportedShowData.dart';
import 'package:castboard_core/storage/Storage.dart';
import 'package:castboard_core/storage/showfile_migration/foldAsyncMigratorValues.dart';

Future<ImportedShowData> migrateToV2(ImportedShowData source) async {
  final subMigrators = [
    _migrateActorIndexDelegate,
    _migrateTrackIndexDelegate,
    _migrateActorThumbnailsDelegate
  ];

  // Asyncronously call each migrator function and reduce the values together.
  return await foldAsyncMigratorValues(source, subMigrators);
}

// ActorIndex Migration Delegate.
Future<ImportedShowData> _migrateActorIndexDelegate(
    ImportedShowData data) async {
  if (data.showData.actorIndex.length >= data.showData.actors.length) {
    // No migration required.
    return data;
  }

  /// We have to define our Map function here with an explicit [ActorIndexBase] class return value.
  /// Otherwise, Dart will implicitly return a List<ActorIndex> list. This will break code in the reducers
  /// at runtime because we will be adding/inserting elements of a List<ActorIndex> not a List<ActorIndexBase> (The base
  /// class that ActorIndex and ActorIndexDivider) derive from.
  ActorIndexBase mapper(ActorRef ref) => ActorIndex(ref);

  return data.copyWith(
      showData: data.showData.copyWith(
    actorIndex: data.showData.actors.keys.map(mapper).toList(),
  ));
}

// TrackIndex Migration Delegate.
Future<ImportedShowData> _migrateTrackIndexDelegate(
    ImportedShowData data) async {
  // TrackIndex Migration.
  if (data.showData.trackIndex.length >= data.showData.tracks.length) {
    // No migration required.
    return data;
  }

  /// We have to define our Map function here with an explicit [TrackIndexBase] class return value.
  /// Otherwise, Dart will implicitly return a List<TrackIndex> list. This will break code in the reducers
  /// at runtime because we will be adding/inserting elements of a List<TrackIndex> not a List<TrackIndexBase> (The base
  /// class that TrackIndex and TrackIndexDivider) derive from.
  TrackIndexBase mapper(TrackRef ref) => TrackIndex(ref);
  return data.copyWith(
      showData: data.showData.copyWith(
    trackIndex: data.showData.tracks.keys.map(mapper).toList(),
  ));
}

Future<ImportedShowData> _migrateActorThumbnailsDelegate(
    ImportedShowData data) async {
  // Collect all ImageRefs of Actors that have headshots associated with them
  final imageRefs = data.showData.actors.values
      .where((model) =>
          model.headshotRef.uid != null && model.headshotRef.uid!.isNotEmpty)
      .map((model) => model.headshotRef);

  final imageRefIds = imageRefs.map((ref) => ref.uid!).toList();
  final imageFiles =
      imageRefs.map((ref) => Storage.instance.getHeadshotFile(ref)!).toList();

  await Storage.instance.addThumbnails(
    imageRefIds,
    imageFiles,
  );

  return data;
}
