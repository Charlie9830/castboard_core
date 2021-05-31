import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/widgets/cast-change-details/CastChangeDetails.dart';

///
/// Takes [basePreset] and combines in the contents of [mixedInPresets] returns a Map of [ActorTuple] that
/// retain information about the original preset the particular assignment came from.
///
///
Map<String, ActorTuple> buildCombinedAssignments(
    PresetModel? basePreset, List<PresetModel> mixedInPresets) {
  if (basePreset == null) {
    return <String, ActorTuple>{};
  }

  final currentAssignmentsAsTuples = basePreset.castChange.map(
    (trackRef, actorRef) => MapEntry(
      trackRef.uid,
      ActorTuple(
        actorRef: actorRef,
        fromNestedPreset: false,
        sourcePresetName: '',
      ),
    ),
  );

  final combinedNestedPresetsAsTuples = mixedInPresets.map(
    (preset) => Map<String, ActorTuple>.from(
      preset.castChange.map(
        (trackRef, actorRef) => MapEntry(
          trackRef.uid,
          ActorTuple(
            actorRef: actorRef,
            sourcePresetName: preset.name,
            fromNestedPreset: true,
          ),
        ),
      ),
    ),
  );

  final assignmentMaps = [
    currentAssignmentsAsTuples,
    ...combinedNestedPresetsAsTuples,
  ];

  if (assignmentMaps.isEmpty) {
    return const <String, ActorTuple>{};
  }

  return assignmentMaps
      .reduce((accum, currentMap) => _nestInPreset(accum, currentMap));
}

/// Return an assignment map representing the merger of current with nesting, item merging predicated on
/// if the item is not set to unassigned.
Map<String, ActorTuple> _nestInPreset(
    Map<String?, ActorTuple> current, Map<String?, ActorTuple> nesting) {
  return Map<String, ActorTuple>.from(current)
    ..addAll(Map<String, ActorTuple>.from(nesting)
      ..removeWhere((key, value) => value.actorRef!.isUnassigned));
}
