import 'package:castboard_core/models/ActorModel.dart';

const _defaultBuiltInPresetId = 'DEFAULT-BUILT-IN-PRESET';

class PresetModel {
  final String uid;
  final String name;
  final String details;
  final bool isNestable;
  final Map<String, String> assignments; // { key: Track, value: Actor }
  final Set<String> _cutTracksSet;

  PresetModel({
    this.uid,
    this.name = '',
    this.details = '',
    this.assignments = const {},
    this.isNestable = false,
  }) : _cutTracksSet = _buildCutTrackSet(assignments);

  const PresetModel.builtIn()
      : uid = _defaultBuiltInPresetId,
        name = 'Default',
        details = '',
        assignments = const {},
        isNestable = false,
        _cutTracksSet = const <String>{};

  PresetModel copyWith({
    String uid,
    String name,
    String details,
    Map<String, String> assignments,
    bool isNestable,
  }) {
    return PresetModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      details: details ?? this.details,
      assignments: assignments ?? this.assignments,
      isNestable: isNestable ?? this.isNestable,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'details': details,
      'assignments': assignments,
      'isNestable': isNestable,
    };
  }

  factory PresetModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return PresetModel(
      uid: map['uid'],
      name: map['name'],
      details: map['details'],
      assignments: Map<String, String>.from(map['assignments']),
      isNestable: map['isNestable'],
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
