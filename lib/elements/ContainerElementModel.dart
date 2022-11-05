import 'package:castboard_core/elements/multi_child_element_model.dart';
import 'package:castboard_core/enum-converters/axisConverters.dart';

import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/enum-converters/containerRunLoadingConverters.dart';
import 'package:castboard_core/enum-converters/crossAxisAlignmentConverters.dart';
import 'package:castboard_core/enum-converters/mainAxisAlignmentConverters.dart';
import 'package:castboard_core/enum-converters/runAlignmentConverters.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:castboard_core/utils/getUid.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../layout-canvas/element_ref.dart';

class ContainerElementModel extends LayoutElementChild
    implements MultiChildElementModel {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final WrapAlignment runAlignment;
  final bool wrapEnabled;
  final Axis axis;
  @override
  final Map<ElementRef, LayoutElementModel> children;
  final ContainerRunLoading runLoading;

  ContainerElementModel({
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    WrapAlignment? runAlignment,
    bool? wrapEnabled,
    Map<ElementRef, LayoutElementModel>? children,
    Axis? axis,
    ContainerRunLoading? runLoading,
  })  : children = children ?? <ElementRef, LayoutElementModel>{},
        mainAxisAlignment = mainAxisAlignment ?? MainAxisAlignment.spaceEvenly,
        crossAxisAlignment = crossAxisAlignment ?? CrossAxisAlignment.center,
        axis = axis ?? Axis.horizontal,
        runAlignment = runAlignment ?? WrapAlignment.center,
        wrapEnabled = wrapEnabled ?? true,
        runLoading = runLoading ?? ContainerRunLoading.topOrLeftHeavy,
        super(updateContracts: <PropertyUpdateContracts>{
          PropertyUpdateContracts.container
        }, canConditionallyRender: false);

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': 'container',
      'axis': convertAxis(axis),
      'mainAxisAlignment': convertMainAxisAlignment(mainAxisAlignment),
      'crossAxisAlignment': convertCrossAxisAlignment(crossAxisAlignment),
      'runAlignment': convertRunAlignment(runAlignment),
      'wrapEnabled': wrapEnabled,
      'children': children.values.map((item) => item.toMap()).toList(),
      'runLoading': convertContainerRunLoading(runLoading),
    };
  }

  ContainerElementModel copyWith(
      {Axis? axis,
      MainAxisAlignment? mainAxisAlignment,
      CrossAxisAlignment? crossAxisAlignment,
      WrapAlignment? runAlignment,
      bool? wrapEnabled,
      Map<ElementRef, LayoutElementModel>? children,
      ContainerRunLoading? runLoading}) {
    return ContainerElementModel(
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      runAlignment: runAlignment ?? this.runAlignment,
      wrapEnabled: wrapEnabled ?? this.wrapEnabled,
      axis: axis ?? this.axis,
      children: children ?? this.children,
      runLoading: runLoading ?? this.runLoading,
    );
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
          ..addAll(children));
  }
}
