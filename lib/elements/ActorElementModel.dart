import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/enum-converters/textAlignConverters.dart';
import 'package:castboard_core/models/ColorModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:flutter/material.dart';

import 'package:castboard_core/elements/TextElementModel.dart';

class ActorElementModel extends TextElementModel {
  final TrackRef trackRef;

  ActorElementModel({
    @required TrackRef trackRef,
    String text,
    String fontFamily = "Arial",
    double fontSize = 24,
    bool italics = false,
    bool bold = false,
    bool underline = false,
    TextAlign alignment = TextAlign.center,
    Color color = Colors.white,
  })  : this.trackRef = trackRef ?? TrackRef.blank(),
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
    TrackRef trackRef,
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
      trackRef: trackRef ?? this.trackRef,
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
      'trackRef': trackRef.toMap(),
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
