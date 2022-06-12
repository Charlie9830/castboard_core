import 'package:castboard_core/enums.dart';
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

  // ImportedShowData ensureMigrated() {
  //   if (manifest.fileVersion == kMaxAllowedFileVersion) {
  //     return this;
  //   }
  // }

  // ImportedShowData _migrateV1toV2() {
  //   // ActorIndex.
  //   if (this.)
  // }
}
