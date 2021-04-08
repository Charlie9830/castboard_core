import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/elements/ActorElementModel.dart';
import 'package:castboard_core/elements/ContainerElement.dart';
import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/elements/HeadshotElementModel.dart';
import 'package:castboard_core/elements/NoActorFallback.dart';
import 'package:castboard_core/elements/NoHeadshotFallback.dart';
import 'package:castboard_core/elements/NoTrackFallback.dart';
import 'package:castboard_core/elements/ShapeElement.dart';
import 'package:castboard_core/elements/ShapeElementModel.dart';
import 'package:castboard_core/elements/TextElement.dart';
import 'package:castboard_core/elements/TextElementModel.dart';
import 'package:castboard_core/elements/TrackElementModel.dart';
import 'package:castboard_core/layout-canvas/LayoutBlock.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/storage/Storage.dart';
import 'package:flutter/material.dart';

Map<String, LayoutBlock> buildElements({
  SlideModel slide,
  PresetModel preset,
  Map<String, ActorModel> actors,
  Map<String, TrackModel> tracks,
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
          tracks: tracks,
        ),
      ),
    ),
  );
}

Widget _buildChild({
  LayoutElementChild element,
  PresetModel selectedPreset,
  Map<String, ActorModel> actors = const {},
  Map<String, TrackModel> tracks = const {},
}) {
  if (element is ContainerElementModel) {
    return ContainerElement(
      alignment: HorizontalAlignment.spaceEvenly, //element.horizontalAlignment,
      children: element.children
          .map((child) => _buildChild(
              element: child,
              selectedPreset: selectedPreset,
              actors: actors,
              tracks: tracks))
          .toList(),
    );
  }

  if (element is HeadshotElementModel) {
    final actor = _getAssignedActor(element, selectedPreset, actors);

    if (tracks == null) {
      return NoTrackFallback();
    }

    final track = tracks[element.trackId];

    if (track == null) {
      return NoTrackFallback();
    }

    if (actor == null) {
      return NoActorFallback(
        trackTitle: track.title,
      );
    }

    if (actor.headshotRef == null || actor.headshotRef.uid.isEmpty) {
      return NoHeadshotFallback(
        trackTitle: track.title,
      );
    }

    return Image.file(
      Storage.instance.getHeadshotFile(actor.headshotRef),
      color: Color.fromARGB(255, 255, 255, 255),
      colorBlendMode: BlendMode.darken,
    );
  }

  if (element is TextElementModel) {
    String text = _lookupText(element, selectedPreset, actors, tracks);

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

String _lookupText(TextElementModel element, PresetModel selectedPreset,
    Map<String, ActorModel> actors, Map<String, TrackModel> tracks) {
  if (element is ActorElementModel) {
    return _lookupActorName(element.trackId, selectedPreset, actors, tracks);
  }

  if (element is TrackElementModel) {
    return _lookupTrackName(element.trackId, selectedPreset, actors, tracks);
  }

  return element.text;
}

String _lookupTrackName(String trackId, PresetModel preset,
    Map<String, ActorModel> actors, Map<String, TrackModel> tracks) {
  if (trackId == null ||
      trackId.isEmpty ||
      tracks == null ||
      tracks.containsKey(trackId) == false) {
    return 'Unassigned';
  }

  return tracks[trackId]?.title ?? 'No Name Track';
}

String _lookupActorName(String trackId, PresetModel preset,
    Map<String, ActorModel> actors, Map<String, TrackModel> tracks) {
  if (trackId == null ||
      trackId.isEmpty ||
      tracks == null ||
      tracks.containsKey(trackId) == false) {
    return 'Unassigned';
  }

  final track = tracks[trackId];
  final trackTitle = track.title == null || track.title.isEmpty
      ? 'No Name Track'
      : track.title;

  if (preset == null) {
    return trackTitle;
  }

  if (preset.assignments == null ||
      preset.assignments.containsKey(trackId) == false) {
    return trackTitle;
  }

  final actor = actors[preset.assignments[trackId]];
  if (actor == null) {
    return "No Actor Found";
  }

  return actor.name;
}

ActorModel _getAssignedActor(HeadshotElementModel element,
    PresetModel selectedPreset, Map<String, ActorModel> actors) {
  if (element == null || selectedPreset?.assignments == null) {
    return null;
  }

  final actorId = selectedPreset.assignments[element.trackId];

  if (actorId == null ||
      actorId == '' ||
      actors.containsKey(actorId) == false) {
    return null;
  }

  return actors[actorId];
}
