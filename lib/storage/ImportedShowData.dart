import 'package:castboard_core/enums.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/RemoteCastChangeData.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/models/ShowDataModel.dart';
import 'package:castboard_core/storage/SlideDataModel.dart';

class ImportedShowData {
  final ManifestModel manifest;
  final Map<String, SlideModel> slides;
  final SlideOrientation slideOrientation;
  final Map<TrackRef, TrackModel> tracks;
  final Map<String, TrackRef> trackRefsByName;
  final Map<ActorRef, ActorModel> actors;
  final Map<String, PresetModel> presets;
  final PlaybackStateData? playbackState;

  ImportedShowData({
    required this.manifest,
    required this.slides,
    required this.slideOrientation,
    required this.tracks,
    required this.trackRefsByName,
    required this.actors,
    required this.presets,
    required this.playbackState,
  });
}
