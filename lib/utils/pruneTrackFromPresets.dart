import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/TrackRef.dart';

Map<String, PresetModel> pruneTrackFromPresets(
    TrackRef trackRef, Map<String, PresetModel> existing) {
  final newPresets = Map<String, PresetModel>.fromEntries(existing.values.map(
      (preset) => MapEntry(
          preset.uid,
          preset.copyWith(
              castChange: preset.castChange.withRemovedAssignment(trackRef)))));

  return newPresets;
}
