import 'package:castboard_core/elements/ActorElementModel.dart';
import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/elements/HeadshotElementModel.dart';
import 'package:castboard_core/elements/ShapeElementModel.dart';
import 'package:castboard_core/elements/TextElementModel.dart';
import 'package:castboard_core/enum-converters/horizontalAlignmentConverters.dart';
import 'package:castboard_core/enum-converters/shapeElementTypeConverters.dart';
import 'package:castboard_core/enum-converters/textAlignConverters.dart';
import 'package:castboard_core/enum-converters/verticalAlignmentConverters.dart';
import 'package:castboard_core/models/ColorModel.dart';

abstract class LayoutElementChild {
  LayoutElementChild();

  Map<String, dynamic> toMap();

  factory LayoutElementChild.fromMap(Map<String, dynamic> map) {
    final String elementType = map['elementType'];

    if (elementType == 'container') {
      return ContainerElementModel(
        horizontalAlignment: parseHorizontalAlignment(map['horiztonalAlignment']),
        verticalAlignment: parseVerticalAlignment(map['verticalAlignment']),
        children: (map['children'] as List<Map<String, dynamic>>)
            .map((Map<String, dynamic> child) =>
                LayoutElementChild.fromMap(child))
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
        roleId: map['roleId'],
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
        roleId: map['roleId'],
      );
    }

    throw Exception(
        'Invalid elementType parameter of LayoutElementChild found during deserialization. elementType = $elementType');
  }
}
