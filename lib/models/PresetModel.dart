import 'package:castboard_core/models/ActorModel.dart';

const _defaultBuiltInPresetId = 'DEFAULT-BUILT-IN-PRESET';

class PresetModel {
  final String uid;
  final String name;
  final String details;
  final Map<String, String> assignments; // { key: Track, value: Actor }
  final Set<String> _cutTracksSet;

  PresetModel({
    this.uid,
    this.name = '',
    this.details = '',
    this.assignments = const {},
  }) : _cutTracksSet = _buildCutTrackSet(assignments);

  const PresetModel.builtIn()
      : uid = _defaultBuiltInPresetId,
        name = 'Default',
        details = '',
        assignments = const {},
        _cutTracksSet = const <String>{};

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

  static Set<String> _buildCutTrackSet(Map<String, String> assignments) {
    if (assignments == null || assignments.values.isEmpty) {
      return <String>{};
    }

    return assignments.values
        .where((id) => id == ActorModel.cutTrackId)
        .toSet();
  }

  bool get isBuiltIn => uid == _defaultBuiltInPresetId;
  Set<String> get cutTrackIds => _cutTracksSet;
}
