import 'dart:convert';

class SubtitleFieldModel {
  final String uid;
  final String fieldName;

  SubtitleFieldModel({
    this.uid = '',
    this.fieldName = '',
  });

  SubtitleFieldModel copyWith({
    String? uid,
    String? fieldName,
    String? value,
  }) {
    return SubtitleFieldModel(
      uid: uid ?? this.uid,
      fieldName: fieldName ?? this.fieldName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fieldName': fieldName,
    };
  }

  factory SubtitleFieldModel.fromMap(Map<String, dynamic> map) {
    return SubtitleFieldModel(
      uid: map['uid'] ?? '',
      fieldName: map['fieldName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SubtitleFieldModel.fromJson(String source) =>
      SubtitleFieldModel.fromMap(json.decode(source));

  @override
  String toString() => 'SubtitleFieldModel(uid: $uid, fieldName: $fieldName)';
}
