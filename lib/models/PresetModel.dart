const _defaultBuiltInPresetId = 'DEFAULT-BUILT-IN-PRESET';

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

  const PresetModel.builtIn()
      : uid = _defaultBuiltInPresetId,
        name = 'Default',
        details = '',
        assignments = const {};

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

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'details': details,
      'assignments': assignments,
    };
  }

  factory PresetModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return PresetModel(
      uid: map['uid'],
      name: map['name'],
      details: map['details'],
      assignments: Map<String, String>.from(map['assignments']),
    );
  }

  bool get isBuiltIn => uid == _defaultBuiltInPresetId;
}
