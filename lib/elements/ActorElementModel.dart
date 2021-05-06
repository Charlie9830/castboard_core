import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/enum-converters/textAlignConverters.dart';
import 'package:castboard_core/models/ColorModel.dart';
import 'package:flutter/material.dart';

import 'package:castboard_core/elements/TextElementModel.dart';

class ActorElementModel extends TextElementModel {
  final String trackId;

  ActorElementModel({
    @required String trackId,
    String text,
    String fontFamily = "Arial",
    double fontSize = 24,
    bool italics = false,
    bool bold = false,
    bool underline = false,
    TextAlign alignment = TextAlign.center,
    Color color = Colors.white,
  })  : this.trackId = trackId ?? '',
        super(
            text: '',
            fontFamily: fontFamily,
            fontSize: fontSize,
            italics: italics,
            bold: bold,
            underline: underline,
            alignment: alignment,
            color: color,
            propertyUpdateContracts: <PropertyUpdateContracts>{
              PropertyUpdateContracts.textStyle,
              PropertyUpdateContracts.trackAssignment,
            },
            canConditionallyRender: true);

  ActorElementModel copyWith({
    String trackId,
    String text,
    String fontFamily,
    double fontSize,
    bool italics,
    bool bold,
    bool underline,
    TextAlign alignment,
    Color color,
  }) {
    return ActorElementModel(
      trackId: trackId ?? this.trackId,
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      italics: italics ?? this.italics,
      bold: bold ?? this.bold,
      underline: underline ?? this.underline,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elementType': 'actor',
      'trackId': trackId,
      'text': text,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'italics': italics,
      'bold': bold,
      'underline': underline,
      'alignment': convertTextAlign(alignment),
      'color': ColorModel.fromColor(color).toMap(),
    };
  }
}
