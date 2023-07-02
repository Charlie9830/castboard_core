import 'dart:io';

import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/playback_state_model.dart';
import 'package:castboard_core/models/ShowDataModel.dart';
import 'package:castboard_core/storage/SlideDataModel.dart';

typedef DataMigrator = ImportedShowData Function(ImportedShowData data);

class ImportedShowData {
  final ManifestModel manifest;
  final SlideDataModel slideData;
  final ShowDataModel showData;
  final PlaybackStateModel? playbackState;

  ImportedShowData({
    required this.manifest,
    required this.slideData,
    required this.showData,
    required this.playbackState,
  });

  ImportedShowData copyWith({
    ManifestModel? manifest,
    SlideDataModel? slideData,
    ShowDataModel? showData,
    PlaybackStateModel? playbackState,
  }) {
    return ImportedShowData(
      manifest: manifest ?? this.manifest,
      slideData: slideData ?? this.slideData,
      showData: showData ?? this.showData,
      playbackState: playbackState ?? this.playbackState,
    );
  }

  static Future<ImportedShowData?> fromDirectory(Directory dir) async {}
}
