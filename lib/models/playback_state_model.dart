import 'package:castboard_core/models/CastChangeModel.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/SlideMetadataModel.dart';

class PlaybackStateModel {
  final String currentPresetId;
  final List<String> combinedPresetIds;
  final CastChangeModel liveCastChangeEdits;
  final Set<String> disabledSlideIds;
  final List<SlideMetadataModel>
      slidesMetadata; // Nominally only Performer -> Remote for Slide Enable/Disable UI.

  PlaybackStateModel({
    required this.currentPresetId,
    required this.combinedPresetIds,
    required this.liveCastChangeEdits,
    required this.disabledSlideIds,
    required this.slidesMetadata,
  });

  const PlaybackStateModel.initial()
      : currentPresetId = kdefaultBuiltInPresetId,
        combinedPresetIds = const [],
        liveCastChangeEdits = const CastChangeModel.initial(),
        disabledSlideIds = const <String>{},
        slidesMetadata = const [];

  Map<String, dynamic> toMap() {
    return {
      'currentPresetId': currentPresetId,
      'combinedPresetIds': combinedPresetIds,
      'activeCastChange': liveCastChangeEdits.toMap(),
      'disabledSlideIds': disabledSlideIds.toList(),
      'slidesMetadata': slidesMetadata.map((slide) => slide.toMap()).toList(),
    };
  }

  factory PlaybackStateModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const PlaybackStateModel.initial();
    }

    return PlaybackStateModel(
        currentPresetId: map['currentPresetId'] ?? '',
        combinedPresetIds: List<String>.from(map['combinedPresetIds'] ?? []),
        liveCastChangeEdits: CastChangeModel.fromMap(map['activeCastChange']),
        disabledSlideIds: ((map['disabledSlideIds'] ?? []) as List<dynamic>)
            .whereType<String>()
            .toSet(),
        slidesMetadata: ((map['slidesMetadata'] ?? []) as List<dynamic>)
            .map((item) => SlideMetadataModel.fromMap(item))
            .toList());
  }
}
