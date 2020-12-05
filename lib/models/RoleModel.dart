import 'package:flutter/foundation.dart';

class RoleModel {
  final String uid;
  final String title;

  RoleModel({
    @required this.uid,
    this.title = '',
  });

  RoleModel copyWith({
    String uid,
    String title,
  }) {
    return RoleModel(
      uid: uid ?? this.uid,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
    };
  }

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return RoleModel(
      uid: map['uid'],
      title: map['title'],
    );
  }
}
