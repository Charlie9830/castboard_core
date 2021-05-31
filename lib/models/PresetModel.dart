import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/CastChangeModel.dart';

const _defaultBuiltInPresetId = 'DEFAULT-BUILT-IN-PRESET';

class PresetModel {
  final String uid;
  final String name;
  final String details;
  final bool isNestable;
  final CastChangeModel castChange;
  final bool createdOnRemote;

  PresetModel({
    required this.uid,
    this.name = '',
    this.details = '',
    this.castChange = const CastChangeModel.initial(),
    this.isNestable = false,
    this.createdOnRemote = false,
  });

  const PresetModel.builtIn()
      : uid = _defaultBuiltInPresetId,
        name = 'Default',
        details = '',
        castChange = const CastChangeModel.initial(),
        isNestable = false,
        createdOnRemote = false;

  PresetModel copyWith({
    String? uid,
    String? name,
    String? details,
    bool? isNestable,
    CastChangeModel? castChange,
    bool? createdOnRemote,
  }) {
    return PresetModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      details: details ?? this.details,
      isNestable: isNestable ?? this.isNestable,
      castChange: castChange ?? this.castChange,
      createdOnRemote: createdOnRemote ?? this.createdOnRemote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'details': details,
      'castChange': castChange.toMap(),
      'isNestable': isNestable,
      'createdOnRemote': createdOnRemote,
    };
  }

  factory PresetModel.fromMap(Map<String, dynamic> map) {
    return PresetModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      details: map['details'] ?? '',
      castChange: CastChangeModel.fromMap(map['castChange']),
      isNestable: map['isNestable'] ?? false,
      createdOnRemote: map['createdOnRemote'] ?? false,
    );
  }

  bool get isBuiltIn => uid == _defaultBuiltInPresetId;
}
