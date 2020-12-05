import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:flutter/foundation.dart';

class HeadshotElementModel extends LayoutElementChild {
  final String roleId;

  HeadshotElementModel({
    @required String roleId,
  }) : this.roleId = roleId ?? '';

  HeadshotElementModel copyWith({
    String roleId,
  }) {
    return HeadshotElementModel(
      roleId: roleId ?? this.roleId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elementType': 'headshot',
      'roleId': roleId,
    };
  }
}
