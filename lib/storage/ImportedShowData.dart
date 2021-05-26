import 'package:castboard_core/classes/StandardSlideSizes.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/SlideSizeModel.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/models/TrackRef.dart';

class ImportedShowData {
  final ManifestModel manifest;
  final Map<String, SlideModel> slides;
  final Map<ActorRef, ActorModel> actors;
  final Map<TrackRef, TrackModel> tracks;
  final Map<String, PresetModel> presets;

  ImportedShowData({
    this.manifest,
    this.slides = const {},
    this.actors = const {},
    this.tracks = const {},
    this.presets = const {},
  });
}
