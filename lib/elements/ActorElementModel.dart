import 'package:castboard_core/elements/TextElementModel.dart';
import 'package:flutter/material.dart';

class ActorElementModel extends TextElementModel {
  final String roleId;

  ActorElementModel({
    this.roleId = '',
    String text,
    String fontFamily = "Arial",
    double fontSize = 24,
    bool italics = false,
    bool bold = false,
    bool underline = false,
    TextAlign alignment = TextAlign.center,
    Color color = Colors.white,
  }) : super(
          text: '',
          fontFamily: fontFamily,
          fontSize: fontSize,
          italics: italics,
          bold: bold,
          underline: underline,
          alignment: alignment,
          color: color,
        );

  ActorElementModel copyWith({
    String roleId,
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
      roleId: roleId ?? this.roleId,
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
}
