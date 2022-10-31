import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/elements/multi_child_element_model.dart';
import 'package:castboard_core/layout-canvas/element_ref.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:castboard_core/utils/getUid.dart';
import 'package:collection/collection.dart';

class GroupElementModel extends LayoutElementChild
    implements MultiChildElementModel {
  @override
  final Map<ElementRef, LayoutElementModel> children;

  GroupElementModel({
    Map<ElementRef, LayoutElementModel>? children,
  })  : children = children ?? <ElementRef, LayoutElementModel>{},
        super(
            updateContracts: <PropertyUpdateContracts>{},
            canConditionallyRender: true);

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': 'group',
      'children': children.values.map((item) => item.toMap()).toList()
    };
  }

  GroupElementModel copyWith({
    Map<ElementRef, LayoutElementModel>? children,
  }) {
    return GroupElementModel(children: children ?? this.children);
  }

  @override
  LayoutElementChild copy({ElementRef? parentId}) {
    if (parentId == null) {
      throw 'LayoutElementChild copy error. If Child implements MultiChildElementModel a parentId MUST be provided to the copy method';
    }

    return copyWith(
      children: Map<ElementRef, LayoutElementModel>.fromEntries(
          children.values.map((child) {
        final newId = parentId.withSuffix(getUid());
        return MapEntry(newId, child.copy(newId));
      })),
    );
  }

  @override
  LayoutElementModel? getChild(ElementRef id) {
    return children[id];
  }

  @override
  LayoutElementChild withRemovedChild(ElementRef id) {
    return copyWith(
      children: Map<ElementRef, LayoutElementModel>.from(children)..remove(id),
    );
  }

  @override
  LayoutElementChild copyWithNewChildrenCollection(
      Map<ElementRef, LayoutElementModel> children) {
    return copyWith(children: children);
  }

  @override
  LayoutElementChild copyWithUpdatedChild(
      ElementRef id, LayoutElementModel element) {
    return copyWith(
        children: Map<ElementRef, LayoutElementModel>.from(children)
          ..update(id, (_) => element));
  }

  @override
  LayoutElementChild copyWithUpdatedChildren(
      Map<ElementRef, LayoutElementModel> children) {
    return copyWith(
      children: Map<ElementRef, LayoutElementModel>.from(children)
        ..addAll(children),
    );
  }
}
