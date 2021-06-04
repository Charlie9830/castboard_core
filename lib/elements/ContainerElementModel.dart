import 'package:castboard_core/enum-converters/axisConverters.dart';

import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/enum-converters/crossAxisAlignmentConverters.dart';
import 'package:castboard_core/enum-converters/mainAxisAlignmentConverters.dart';
import 'package:castboard_core/enum-converters/runAlignmentConverters.dart';
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

  ContainerElementModel({
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    WrapAlignment? runAlignment,
    bool? wrapEnabled,
    List<LayoutElementModel>? children,
    Axis? axis,
  })  : this.children = children ?? <LayoutElementModel>[],
        this.mainAxisAlignment = mainAxisAlignment ?? MainAxisAlignment.center,
        this.crossAxisAlignment =
            crossAxisAlignment ?? CrossAxisAlignment.center,
        this.axis = axis ?? Axis.horizontal,
        this.runAlignment = runAlignment ?? WrapAlignment.start,
        this.wrapEnabled = wrapEnabled ?? false,
        super(updateContracts: <PropertyUpdateContracts>{
          PropertyUpdateContracts.container
        }, canConditionallyRender: false);

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': 'container',
      'axis': convertAxis(this.axis),
      'mainAxisAlignment': convertMainAxisAlignment(this.mainAxisAlignment),
      'crossAxisAlignment': convertCrossAxisAlignment(this.crossAxisAlignment),
      'runAlignment': convertRunAlignment(this.runAlignment),
      'wrapEnabled': wrapEnabled,
      'children': children.map((item) => item.toMap()).toList()
    };
  }

  ContainerElementModel copyWith({
    Axis? axis,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    WrapAlignment? runAlignment,
    bool? wrapEnabled,
    List<LayoutElementModel>? children,
  }) {
    return ContainerElementModel(
        mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
        runAlignment: runAlignment ?? this.runAlignment,
        wrapEnabled: wrapEnabled ?? this.wrapEnabled,
        axis: axis ?? this.axis,
        children: children ?? this.children);
  }

  @override
  LayoutElementChild copy() {
    return copyWith(
      children: children.map((child) => child.copy(getUid())).toList(),
    );
  }
}
