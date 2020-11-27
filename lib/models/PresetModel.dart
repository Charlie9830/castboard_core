class PresetModel {
  final String uid;
  final String name;
  final String details;
  final Map<String, String> assignments;

  PresetModel({
    this.uid,
    this.name = '',
    this.details = '',
    this.assignments = const {},
  });

  PresetModel copyWith({
    String uid,
    String name,
    String details,
    Map<String, String> assignments,
  }) {
    return PresetModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      details: details ?? this.details,
      assignments: assignments ?? this.assignments,
    );
  }
}
