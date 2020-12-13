import 'package:flutter/foundation.dart';

class RoleModel {
  final String uid;
  final String title;
  final String internalTitle;

  RoleModel({
    @required this.uid,
    this.title = '',
    this.internalTitle = '',
  });

  RoleModel copyWith({
    String uid,
    String title,
    String internalTitle,
  }) {
    return RoleModel(
      uid: uid ?? this.uid,
      title: title ?? this.title,
      internalTitle: internalTitle ?? this.internalTitle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'internalTitle': internalTitle,
    };
  }

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return RoleModel(
      uid: map['uid'],
      title: map['title'],
      internalTitle: map['internalTitle'],
    );
  }
}
