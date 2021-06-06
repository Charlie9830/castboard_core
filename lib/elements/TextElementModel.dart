

import 'package:castboard_core/enum-converters/textAlignConverters.dart';
import 'package:castboard_core/models/ColorModel.dart';
import 'package:flutter/material.dart';

import 'package:castboard_core/classes/LayoutElementChild.dart';

class TextElementModel extends LayoutElementChild {
  final String text;
  final String fontFamily;
  final double fontSize;
  final bool italics;
  final bool bold;
  final bool underline;
  final TextAlign alignment;
  final Color color;

  TextElementModel({
    Set<PropertyUpdateContracts>? propertyUpdateContracts,
    bool? canConditionallyRender,
    String? text,
    String? fontFamily,
    double? fontSize,
    bool? italics,
    bool? bold,
    bool? underline,
    TextAlign? alignment,
    Color? color,
  })  : this.text = text ?? '',
        this.fontFamily = fontFamily ?? 'Arial',
        this.fontSize = fontSize ?? 48,
        this.italics = italics ?? false,
        this.bold = bold ?? false,
        this.underline = underline ?? false,
        this.alignment = alignment ?? TextAlign.center,
        this.color = color ?? Colors.black,
        super(
            updateContracts: propertyUpdateContracts ??
                <PropertyUpdateContracts>{
                  PropertyUpdateContracts.textData,
                  PropertyUpdateContracts.textStyle,
                },
            canConditionallyRender: canConditionallyRender ?? false);

  TextElementModel copyWith({
    String? text,
    String? fontFamily,
    double? fontSize,
    bool? italics,
    bool? bold,
    bool? underline,
    TextAlign? alignment,
    Color? color,
  }) {
    return TextElementModel(
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
      'elementType': 'text',
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

  @override
  LayoutElementChild copy() {
    return copyWith();
  }
}
