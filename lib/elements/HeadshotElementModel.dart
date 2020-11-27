
import 'package:castboard_core/classes/LayoutElementChild.dart';

class HeadshotElementModel extends LayoutElementChild {
  final String roleId;

  HeadshotElementModel({
    this.roleId = '',
  });

  HeadshotElementModel copyWith({
    String roleId,
  }) {
    return HeadshotElementModel(
      roleId: roleId ?? this.roleId,
    );
  }
}
