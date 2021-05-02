import 'package:castboard_core/elements/ActorElementModel.dart';
import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/elements/HeadshotElementModel.dart';
import 'package:castboard_core/elements/ShapeElementModel.dart';
import 'package:castboard_core/elements/TextElementModel.dart';
import 'package:castboard_core/elements/TrackElementModel.dart';
import 'package:castboard_core/enum-converters/axisConverters.dart';
import 'package:castboard_core/enum-converters/mainAxisAlignmentConverters.dart';
import 'package:castboard_core/enum-converters/shapeElementTypeConverters.dart';
import 'package:castboard_core/enum-converters/textAlignConverters.dart';
import 'package:castboard_core/enum-converters/crossAxisAlignmentConverters.dart';
import 'package:castboard_core/models/ColorModel.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';

enum PropertyUpdateContracts {
  textData,
  textStyle,
  trackAssignment,
  container,
}

abstract class LayoutElementChild {
  LayoutElementChild(this.propertyUpdateContracts);

  final Set<PropertyUpdateContracts> propertyUpdateContracts;

  Map<String, dynamic> toMap();

  factory LayoutElementChild.fromMap(Map<String, dynamic> map) {
    final String elementType = map['elementType'];

    if (elementType == 'container') {
      return ContainerElementModel(
        axis: parseAxis(map['axis']),
        children: (map['children'] as List<Map<String, dynamic>>)
            .map((Map<String, dynamic> child) =>
                LayoutElementModel.fromMap(child))
            .toList(),
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
        color: ColorModel.fromMap(map['color'])?.toColor(),
      );
    }

    if (elementType == 'actor') {
      return ActorElementModel(
        trackId: map['trackId'],
        fontFamily: map['fontFamily'],
        fontSize: map['fontSize'],
        italics: map['italics'],
        bold: map['bold'],
        underline: map['underline'],
        alignment: parseTextAlign(map['alignment']),
        color: ColorModel.fromMap(map['color'])?.toColor(),
      );
    }

    if (elementType == 'track') {
      return TrackElementModel(
        trackId: map['trackId'],
        fontFamily: map['fontFamily'],
        fontSize: map['fontSize'],
        italics: map['italics'],
        bold: map['bold'],
        underline: map['underline'],
        alignment: parseTextAlign(map['alignment']),
        color: ColorModel.fromMap(map['color'])?.toColor(),
      );
    }

    if (elementType == 'shape') {
      return ShapeElementModel(
        type: parseShapeElementType(map['type']),
        fill: ColorModel.fromMap(map['fill'])?.toColor(),
        lineColor: ColorModel.fromMap(map['lineColor'])?.toColor(),
        lineWeight: map['lineWeight'],
      );
    }

    if (elementType == 'headshot') {
      return HeadshotElementModel(
        trackId: map['trackId'],
      );
    }

    throw Exception(
        'Invalid elementType parameter of LayoutElementChild found during deserialization. elementType = $elementType');
  }
}
