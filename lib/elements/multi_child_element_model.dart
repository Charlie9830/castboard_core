import 'package:castboard_core/layout-canvas/element_ref.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:collection/collection.dart';

abstract class MultiChildElementModel {
  final Map<ElementRef, LayoutElementModel> children;

  LayoutElementModel? getChild(ElementRef id);

  MultiChildElementModel(this.children);
}
