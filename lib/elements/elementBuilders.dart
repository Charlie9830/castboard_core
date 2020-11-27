import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/elements/ActorElementModel.dart';
import 'package:castboard_core/elements/HeadshotElementModel.dart';
import 'package:castboard_core/elements/NoActorFallback.dart';
import 'package:castboard_core/elements/NoHeadshotFallback.dart';
import 'package:castboard_core/elements/NoRoleFallback.dart';
import 'package:castboard_core/elements/ShapeElement.dart';
import 'package:castboard_core/elements/ShapeElementModel.dart';
import 'package:castboard_core/elements/TextElement.dart';
import 'package:castboard_core/elements/TextElementModel.dart';
import 'package:castboard_core/layout-canvas/LayoutBlock.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/RoleModel.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/storage/Storage.dart';
import 'package:flutter/material.dart';

Map<String, LayoutBlock> buildElements({
  SlideModel slide,
  PresetModel preset,
  Map<String, ActorModel> actors,
  Map<String, RoleModel> roles,
}) {
  final Map<String, LayoutElementModel> elements =
      slide?.elements ?? <String, LayoutElementModel>{};

  return elements.map(
    (id, element) => MapEntry(
      id,
      LayoutBlock(
        id: id,
        width: element.width,
        height: element.height,
        xPos: element.xPos,
        yPos: element.yPos,
        rotation: element.rotation,
        child: _buildChild(
          element: element.child,
          selectedPreset: preset,
          actors: actors,
          roles: roles,
        ),
      ),
    ),
  );
}

Widget _buildChild({
  LayoutElementChild element,
  PresetModel selectedPreset,
  Map<String, ActorModel> actors = const {},
  Map<String, RoleModel> roles = const {},
}) {
  if (element is HeadshotElementModel) {
    final actor = _getAssignedActor(element, selectedPreset, actors);

    if (roles == null) {
      return NoRoleFallback();
    }

    final role = roles[element.roleId];

    if (role == null) {
      return NoRoleFallback();
    }

    if (actor == null) {
      return NoActorFallback(
        roleTitle: role.title,
      );
    }

    if (actor.headshotRef == null || actor.headshotRef.uid.isEmpty) {
      return NoHeadshotFallback(
        roleTitle: role.title,
      );
    }

    return Image.file(
      Storage.instance.getHeadshotFile(actor.headshotRef),
      color: Color.fromARGB(255, 255, 255, 255),
      colorBlendMode: BlendMode.darken,
    );
  }

  if (element is TextElementModel) {
    final text = element is ActorElementModel
        ? _lookupActorName(element.roleId, selectedPreset, actors, roles)
        : element.text;
    return TextElement(
      text: text,
      style: TextElementStyle(
          alignment: element.alignment,
          color: element.color,
          fontFamily: element.fontFamily,
          fontSize: element.fontSize,
          bold: element.bold,
          italics: element.italics,
          underline: element.underline),
    );
  }

  if (element is ShapeElementModel) {
    return ShapeElement(
      type: element.type,
      fill: element.fill,
      lineColor: element.lineColor,
      lineWeight: element.lineWeight,
    );
  }

  return SizedBox.fromSize(size: Size.zero);
}

String _lookupActorName(String roleId, PresetModel preset,
    Map<String, ActorModel> actors, Map<String, RoleModel> roles) {
  if (roleId == null ||
      roleId.isEmpty ||
      roles == null ||
      roles.containsKey(roleId) == false) {
    return 'Unassigned Role';
  }

  final role = roles[roleId];
  final roleTitle =
      role.title == null || role.title.isEmpty ? 'No Name Role' : role.title;

  if (preset == null) {
    return roleTitle;
  }

  if (preset.assignments == null ||
      preset.assignments.containsKey(roleId) == false) {
    return roleTitle;
  }

  final actor = actors[preset.assignments[roleId]];
  if (actor == null) {
    return "Could find actor";
  }

  return actor.name;
}

ActorModel _getAssignedActor(HeadshotElementModel element,
    PresetModel selectedPreset, Map<String, ActorModel> actors) {
  if (element == null || selectedPreset?.assignments == null) {
    return null;
  }

  final actorId = selectedPreset.assignments[element.roleId];

  if (actorId == null ||
      actorId == '' ||
      actors.containsKey(actorId) == false) {
    return null;
  }

  return actors[actorId];
}
