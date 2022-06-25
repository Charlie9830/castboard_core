import 'package:castboard_core/enum-converters/axisConverters.dart';

import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/enum-converters/containerRunLoadingConverters.dart';
import 'package:castboard_core/enum-converters/crossAxisAlignmentConverters.dart';
import 'package:castboard_core/enum-converters/mainAxisAlignmentConverters.dart';
import 'package:castboard_core/enum-converters/runAlignmentConverters.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:castboard_core/utils/getUid.dart';
import 'package:flutter/widgets.dart';

class ContainerElementModel extends LayoutElementChild {
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final WrapAlignment runAlignment;
  final bool wrapEnabled;
  final Axis axis;
  final List<LayoutElementModel> children;
  final ContainerRunLoading runLoading;

  ContainerElementModel({
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    WrapAlignment? runAlignment,
    bool? wrapEnabled,
    List<LayoutElementModel>? children,
    Axis? axis,
    ContainerRunLoading? runLoading,
  })  : children = children ?? <LayoutElementModel>[],
        mainAxisAlignment = mainAxisAlignment ?? MainAxisAlignment.center,
        crossAxisAlignment =
            crossAxisAlignment ?? CrossAxisAlignment.center,
        axis = axis ?? Axis.horizontal,
        runAlignment = runAlignment ?? WrapAlignment.start,
        wrapEnabled = wrapEnabled ?? false,
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
      'children': children.map((item) => item.toMap()).toList(),
      'runLoading': convertContainerRunLoading(runLoading),
    };
  }

  ContainerElementModel copyWith(
      {Axis? axis,
      MainAxisAlignment? mainAxisAlignment,
      CrossAxisAlignment? crossAxisAlignment,
      WrapAlignment? runAlignment,
      bool? wrapEnabled,
      List<LayoutElementModel>? children,
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
  LayoutElementChild copy() {
    return copyWith(
      children: children.map((child) => child.copy(getUid())).toList(),
    );
  }
}
