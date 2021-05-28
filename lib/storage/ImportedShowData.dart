import 'package:castboard_core/enums.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/storage/ShowDataModel.dart';
import 'package:castboard_core/storage/SlideDataModel.dart';

class ImportedShowData {
  final ManifestModel manifest;
  final Map<String, SlideModel> slides;
  final String slideSizeId;
  final SlideOrientation slideOrientation;
  final Map<TrackRef, TrackModel> tracks;
  final Map<ActorRef, ActorModel> actors;
  final Map<String, PresetModel> presets;

  ImportedShowData({
    this.manifest,
    this.slides,
    this.slideSizeId,
    this.slideOrientation,
    this.tracks,
    this.actors,
    this.presets
  });
}
