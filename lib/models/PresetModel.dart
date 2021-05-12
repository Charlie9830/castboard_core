import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/CastChangeModel.dart';

const _defaultBuiltInPresetId = 'DEFAULT-BUILT-IN-PRESET';

class PresetModel {
  final String uid;
  final String name;
  final String details;
  final bool isNestable;
  final CastChangeModel castChange; // { key: Track, value: Actor }

  PresetModel({
    this.uid,
    this.name = '',
    this.details = '',
    this.castChange = const CastChangeModel.initial(),
    this.isNestable = false,
  });

  const PresetModel.builtIn()
      : uid = _defaultBuiltInPresetId,
        name = 'Default',
        details = '',
        castChange = const CastChangeModel.initial(),
        isNestable = false;

  PresetModel copyWith({
    String uid,
    String name,
    String details,
    CastChangeModel castChange,
    bool isNestable,
  }) {
    return PresetModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      details: details ?? this.details,
      castChange: castChange ?? this.castChange,
      isNestable: isNestable ?? this.isNestable,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'details': details,
      'castChange': castChange.toMap(),
      'isNestable': isNestable,
    };
  }

  factory PresetModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return PresetModel(
      uid: map['uid'],
      name: map['name'],
      details: map['details'],
      castChange: CastChangeModel.fromMap(map['castChange']),
      isNestable: map['isNestable'],
    );
  }

  bool get isBuiltIn => uid == _defaultBuiltInPresetId;
}
