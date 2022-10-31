import 'dart:io';

import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/elements/GroupElementModel.dart';
import 'package:castboard_core/layout-canvas/element_ref.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/storage/ImportedShowData.dart';
import 'package:castboard_core/utils/getUid.dart';

Future<ImportedShowData> migrateToV3(
  ImportedShowData source,
  Directory baseDir,
) async {
  // V3 adds PresetModel.colorTag and removed PresetModel.isNestable. However the migratory behaviour is handled
  // implicitly.
  // V3 Changes Element Ids from String type to tiered ElementRef Type.
  return source.copyWith(
      slideData: source.slideData.copyWith(
          slides: Map<String, SlideModel>.from(source.slideData.slides)
            ..updateAll((key, slide) =>
                slide.copyWith(elements: _migrateElementIds(slide.elements)))));
}

Map<ElementRef, LayoutElementModel> _migrateElementIds(
  Map<ElementRef, LayoutElementModel> existing, {
  ElementRef? parentId,
}) {
  final updatedElements = existing.values.map((element) {
    return element.copyWith(
        uid: parentId ?? element.uid,
        child: _updateChildId(parentId ?? element.uid, element.child));
  });

  return Map<ElementRef, LayoutElementModel>.fromEntries(
      updatedElements.map((item) => MapEntry(item.uid, item)));
}

LayoutElementChild _updateChildId(
    ElementRef parentId, LayoutElementChild child) {
  if (child is GroupElementModel) {
    return child.copyWith(children:
        Map<ElementRef, LayoutElementModel>.fromEntries(
            child.children.values.map((item) {
      final newId = parentId.withSuffix(getUid());
      return MapEntry(newId,
          item.copyWith(uid: newId, child: _updateChildId(newId, item.child)));
    })));
  }

  if (child is ContainerElementModel) {
    return child.copyWith(children:
        Map<ElementRef, LayoutElementModel>.fromEntries(
            child.children.values.map((item) {
      final newId = parentId.withSuffix(getUid());
      return MapEntry(newId,
          item.copyWith(uid: newId, child: _updateChildId(newId, item.child)));
    })));
  }

  return child;
}
