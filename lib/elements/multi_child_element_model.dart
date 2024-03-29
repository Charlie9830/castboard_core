import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/layout-canvas/element_ref.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';

abstract class MultiChildElementModel {
  final Map<ElementRef, LayoutElementModel> children;

  LayoutElementModel? getChild(ElementRef id);

  LayoutElementChild withRemovedChild(ElementRef id);

  LayoutElementChild copyWithNewChildrenCollection(
      Map<ElementRef, LayoutElementModel> children);

  LayoutElementChild copyWithUpdatedChild(
      ElementRef id, LayoutElementModel element);

  LayoutElementChild copyWithUpdatedChildren(
    Map<ElementRef, LayoutElementModel> children,
  );

  MultiChildElementModel(this.children);

  LayoutElementChild copyWithUpdatedParentId(ElementRef parentId);
}
