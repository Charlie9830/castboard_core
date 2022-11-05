import 'package:flutter/material.dart';

import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/elements/TextElement.dart';
import 'package:castboard_core/enum-converters/textAlignConverters.dart';
import 'package:castboard_core/layout-canvas/element_ref.dart';
import 'package:castboard_core/models/ColorModel.dart';

class TextElementModel extends LayoutElementChild {
  final String text;
  final String fontFamily;
  final double fontSize;
  final bool italics;
  final bool bold;
  final bool underline;
  final TextAlign alignment;
  final Color color;
  final bool needsInterpolation;
  final Color shadowColor;
  final double shadowXOffset;
  final double shadowYOffset;
  final double shadowBlurRadius;

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
    bool? needsInterpolation,
    Color? shadowColor,
    double? shadowXOffset,
    double? shadowYOffset,
    double? shadowBlurRadius,
  })  : text = text ?? '',
        fontFamily = fontFamily ?? 'Arial',
        fontSize = fontSize ?? 48,
        italics = italics ?? false,
        bold = bold ?? false,
        underline = underline ?? false,
        alignment = alignment ?? TextAlign.center,
        color = color ?? Colors.black,
        needsInterpolation = _hasInterpolation(text),
        shadowColor = shadowColor ?? Colors.black,
        shadowBlurRadius = shadowBlurRadius ?? 0,
        shadowXOffset = shadowXOffset ?? 0,
        shadowYOffset = shadowYOffset ?? 0,
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
    Color? shadowColor,
    double? shadowXOffset,
    double? shadowYOffset,
    double? shadowBlurRadius,
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
      shadowColor: shadowColor ?? this.shadowColor,
      shadowXOffset: shadowXOffset ?? this.shadowXOffset,
      shadowYOffset: shadowYOffset ?? this.shadowYOffset,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
    );
  }

  @override
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
      'shadowColor': ColorModel.fromColor(color).toMap(),
      'shadowXOffset': shadowXOffset,
      'shadowYOffset': shadowYOffset,
      'shadowBlurRadius': shadowBlurRadius,
    };
  }

  @override
  LayoutElementChild copy({ElementRef? parentId}) {
    return copyWith();
  }

  TextElementStyle get style => TextElementStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        bold: bold,
        italics: italics,
        underline: underline,
        alignment: alignment,
        color: color,
      );

  static bool _hasInterpolation(String? input) {
    if (input == null) return false;

    final regex = RegExp('{.+}');
    return regex.hasMatch(input);
  }

  static RegExp matchInterpolationRegex = RegExp('{.+}');
  static RegExp matchInterpolationOperatorsRegex = RegExp('[{|}]');
}
