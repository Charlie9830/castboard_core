import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:castboard_core/utils/getUid.dart';

class GroupElementModel extends LayoutElementChild {
  final List<LayoutElementModel> children;

  GroupElementModel({
    List<LayoutElementModel>? children,
  })  : children = children ?? <LayoutElementModel>[],
        super(
            updateContracts: <PropertyUpdateContracts>{},
            canConditionallyRender: true);

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': 'group',
      'children': children.map((item) => item.toMap()).toList()
    };
  }

  GroupElementModel copyWith({
    List<LayoutElementModel>? children,
  }) {
    return GroupElementModel(children: children ?? this.children);
  }

  @override
  LayoutElementChild copy() {
    return copyWith(
      children: children.map((child) => child.copy(getUid())).toList(),
    );
  }
}
