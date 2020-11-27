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
}
