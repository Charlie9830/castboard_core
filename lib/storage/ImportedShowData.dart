import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/SlideModel.dart';

class ImportedShowData {
  final ManifestModel manifest;
  final Map<String, SlideModel> slides;
  final Map<String, ActorModel> actors;
  final Map<String, TrackModel> tracks;
  final Map<String, PresetModel> presets;

  ImportedShowData({
    this.manifest,
    this.slides = const {},
    this.actors = const {},
    this.tracks = const {},
    this.presets = const {},
  });
}
