import 'package:castboard_core/models/CastChangeModel.dart';

class PlaybackStateData {
  final String currentPresetId;
  final List<String> combinedPresetIds;
  final CastChangeModel liveCastChangeEdits;

  PlaybackStateData({
    required this.currentPresetId,
    required this.combinedPresetIds,
    required this.liveCastChangeEdits,
  });

  PlaybackStateData.initial()
      : currentPresetId = '',
        combinedPresetIds = const [],
        liveCastChangeEdits = const CastChangeModel.initial();

  Map<String, dynamic> toMap() {
    return {
      'currentPresetId': currentPresetId,
      'combinedPresetIds': combinedPresetIds,
      'activeCastChange': liveCastChangeEdits.toMap(),
    };
  }

  factory PlaybackStateData.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return PlaybackStateData.initial();
    }

    return PlaybackStateData(
      currentPresetId: map['currentPresetId'] ?? '',
      combinedPresetIds: List<String>.from(map['combinedPresetIds'] ?? []),
      liveCastChangeEdits: CastChangeModel.fromMap(map['activeCastChange']),
    );
  }
}
