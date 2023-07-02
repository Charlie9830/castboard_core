import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/elements/ActorElementModel.dart';
import 'package:castboard_core/elements/BlankElementModel.dart';
import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/elements/GroupElementModel.dart';
import 'package:castboard_core/elements/HeadshotElementModel.dart';
import 'package:castboard_core/elements/ImageElementModel.dart';
import 'package:castboard_core/elements/ShapeElementModel.dart';
import 'package:castboard_core/elements/TextElementModel.dart';
import 'package:castboard_core/elements/TrackElementModel.dart';
import 'package:castboard_core/enum-converters/axisConverters.dart';
import 'package:castboard_core/enum-converters/containerRunLoadingConverters.dart';
import 'package:castboard_core/enum-converters/mainAxisAlignmentConverters.dart';
import 'package:castboard_core/enum-converters/runAlignmentConverters.dart';
import 'package:castboard_core/enum-converters/shapeElementTypeConverters.dart';
import 'package:castboard_core/enum-converters/textAlignConverters.dart';
import 'package:castboard_core/enum-converters/crossAxisAlignmentConverters.dart';
import 'package:castboard_core/layout-canvas/element_ref.dart';
import 'package:castboard_core/models/ColorModel.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:flutter/material.dart';

enum PropertyUpdateContracts {
  textData,
  textStyle,
  trackAssignment,
  container,
  shape,
}

abstract class LayoutElementChild {
  LayoutElementChild({this.updateContracts, this.canConditionallyRender});

  final Set<PropertyUpdateContracts>? updateContracts;
  final bool? canConditionallyRender;

  Map<String, dynamic> toMap();

  LayoutElementChild copy({ElementRef? parentId});

  factory LayoutElementChild.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return BlankElementModel();
    }

    final String? elementType = map['elementType'];

    if (elementType == 'blank') {
      return BlankElementModel();
    }

    if (elementType == 'container') {
      return ContainerElementModel(
        mainAxisAlignment: parseMainAxisAlignment(map['mainAxisAlignment']),
        crossAxisAlignment: parseCrossAxisAlignment(map['crossAxisAlignment']),
        runAlignment: parseRunAlignment(map['runAlignment']),
        wrapEnabled: map['wrapEnabled'],
        axis: parseAxis(map['axis']),
        children: _parseChildrenListToMap(map['children'] as List<dynamic>),
        runLoading:
            parseContainerRunLoading(map['runLoading'] ?? 'topOrLeftHeavy'),
      );
    }

    if (elementType == 'group') {
      return GroupElementModel(
        children: _parseChildrenListToMap(map['children'] as List<dynamic>),
      );
    }

    if (elementType == 'text') {
      return TextElementModel(
        text: map['text'],
        fontFamily: map['fontFamily'],
        fontSize: map['fontSize'],
        italics: map['italics'],
        bold: map['bold'],
        underline: map['underline'],
        alignment: parseTextAlign(map['alignment']),
        color: ColorModel.fromMap(map['color']).toColor(),
        shadowColor: map['shadowColor'] != null
            ? ColorModel.fromMap(map['shadowColor']).toColor()
            : Colors.black,
        shadowXOffset: map['shadowXOffset'] ?? 0,
        shadowYOffset: map['shadowYOffset'] ?? 0,
        shadowBlurRadius: map['shadowBlurRadius'] ?? 0,
      );
    }

    if (elementType == 'actor') {
      return ActorElementModel(
        trackRef: TrackRef.fromMap(map['trackRef']),
        fontFamily: map['fontFamily'],
        fontSize: map['fontSize'],
        italics: map['italics'],
        bold: map['bold'],
        underline: map['underline'],
        alignment: parseTextAlign(map['alignment']),
        color: ColorModel.fromMap(map['color']).toColor(),
        shadowColor: map['shadowColor'] != null
            ? ColorModel.fromMap(map['shadowColor']).toColor()
            : Colors.black,
        shadowXOffset: map['shadowXOffset'] ?? 0,
        shadowYOffset: map['shadowYOffset'] ?? 0,
        shadowBlurRadius: map['shadowBlurRadius'] ?? 0,
        subtitleFieldId: map['subtitleFieldId'] ?? '',
      );
    }

    if (elementType == 'track') {
      return TrackElementModel(
        trackRef: TrackRef.fromMap(map['trackRef']),
        fontFamily: map['fontFamily'],
        fontSize: map['fontSize'],
        italics: map['italics'],
        bold: map['bold'],
        underline: map['underline'],
        alignment: parseTextAlign(map['alignment']),
        color: ColorModel.fromMap(map['color']).toColor(),
        shadowColor: map['shadowColor'] != null
            ? ColorModel.fromMap(map['shadowColor']).toColor()
            : Colors.black,
        shadowXOffset: map['shadowXOffset'] ?? 0,
        shadowYOffset: map['shadowYOffset'] ?? 0,
        shadowBlurRadius: map['shadowBlurRadius'] ?? 0,
      );
    }

    if (elementType == 'shape') {
      return ShapeElementModel(
        type: parseShapeElementType(map['type']),
        fill: ColorModel.fromMap(map['fill']).toColor(),
        lineColor: ColorModel.fromMap(map['lineColor']).toColor(),
        lineWeight: map['lineWeight'],
      );
    }

    if (elementType == 'image') {
      return ImageElementModel(ref: ImageRef.fromMap(map['ref']));
    }

    if (elementType == 'headshot') {
      return HeadshotElementModel(
        trackRef: TrackRef.fromMap(map['trackRef']),
      );
    }

    throw Exception(
        'Invalid elementType parameter of LayoutElementChild found during deserialization. elementType = $elementType');
  }

  static Map<ElementRef, LayoutElementModel> _parseChildrenListToMap(
      List<dynamic> children) {
    final list = children.map((child) => LayoutElementModel.fromMap(child));

    return Map<ElementRef, LayoutElementModel>.fromEntries(
        list.map((item) => MapEntry(item.uid, item)));
  }
}
