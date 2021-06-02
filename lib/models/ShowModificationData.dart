class ShowModificationData {
  final Set<String> freshPresetIds;
  final Set<String> editedPresetIds;
  final Set<String> deletedPresetIds;

  ShowModificationData({
    required this.freshPresetIds,
    required this.editedPresetIds,
    required this.deletedPresetIds,
  });

  ShowModificationData.initial()
      : freshPresetIds = const {},
        editedPresetIds = const {},
        deletedPresetIds = const {};

  Map<String, dynamic> toMap() {
    return {
      'freshPresetIds': freshPresetIds.toList(),
      'editedPresetIds': editedPresetIds.toList(),
      'deletedPresetIds': deletedPresetIds.toList(),
    };
  }

  factory ShowModificationData.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ShowModificationData.initial();
    }

    return ShowModificationData(
      freshPresetIds: Set<String>.from(map['freshPresetIds'] ?? []),
      editedPresetIds: Set<String>.from(map['editedPresetIds'] ?? []),
      deletedPresetIds: Set<String>.from(map['deletedPresetIds'] ?? []),
    );
  }
}
