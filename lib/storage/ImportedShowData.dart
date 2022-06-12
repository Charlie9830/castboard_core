import 'package:castboard_core/enums.dart';
import 'package:castboard_core/models/ActorIndex.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/RemoteCastChangeData.dart';
import 'package:castboard_core/models/ShowDataModel.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/storage/SlideDataModel.dart';
import 'package:castboard_core/version/fileVersion.dart';

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

  static ImportedShowData _migrateToV2(ImportedShowData data) {
    // ActorIndex.
    if (data.showData.actorIndex.length >= data.showData.actors.length) {
      // No migration required.
      return data;
    }

    return data._copyWith(
        showData: data.showData.copyWith(
      actorIndex:
          data.showData.actors.keys.map((ref) => ActorIndex(ref)).toList(),
    ));
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
}
