import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/PresetModel.dart';

Map<String, PresetModel> pruneActorFromPresets(
    ActorRef actorRef, Map<String, PresetModel> existing) {
  final newPresets = Map<String, PresetModel>.fromEntries(
    existing.values.map((preset) {
      return MapEntry(
          preset.uid,
          preset.copyWith(
              castChange: preset.castChange.withPrunedActor(actorRef)));
    }),
  );

  return newPresets;
}