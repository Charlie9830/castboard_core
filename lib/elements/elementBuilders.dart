import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/elements/ActorElementModel.dart';
import 'package:castboard_core/elements/ContainerElement.dart';
import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/elements/ContainerItem.dart';
import 'package:castboard_core/elements/ImageElement.dart';
import 'package:castboard_core/layout-canvas/MultiChildCanvasItem.dart';
import 'package:castboard_core/elements/GroupElementModel.dart';
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

typedef void OnContainerItemsReorder(
    String containerId, String itemId, int oldIndex, int newIndex);

Map<String, LayoutBlock> buildElements({
  SlideModel slide,
  PresetModel preset,
  Map<String, ActorModel> actors,
  Map<String, TrackModel> tracks,
  OnContainerItemsReorder onContainerItemsReorder,
  String editingContainerId = '',
  String highlightedContainerId = '',
  bool isInSlideEditor = false,
  dynamic onContainerItemClick,
  Set<String> selectedContainerItemIds,
}) {
  final Map<String, LayoutElementModel> elements =
      slide?.elements ?? <String, LayoutElementModel>{};

  return Map<String, LayoutBlock>.fromEntries(
    elements.values.where((element) => _shouldBuild(element, preset)).map(
      (element) {
        final id = element.uid;
        final isEditingContainer =
            editingContainerId != null && id == editingContainerId;
        return MapEntry(
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
              elementPadding: EdgeInsets.fromLTRB(
                  element.leftPadding?.toDouble() ?? 0,
                  element.topPadding?.toDouble() ?? 0,
                  element.rightPadding?.toDouble() ?? 0,
                  element.bottomPadding?.toDouble() ?? 0),
              isInSlideEditor: isInSlideEditor,
              isEditingContainer: isEditingContainer,
              isHighlighted: isEditingContainer || highlightedContainerId == id,
              onContainerItemsReorder: (itemId, oldIndex, newIndex) =>
                  onContainerItemsReorder?.call(id, itemId, oldIndex, newIndex),
              onItemClick: onContainerItemClick,
              selectedContainerIds: selectedContainerItemIds,
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildChild({
  LayoutElementChild element,
  PresetModel selectedPreset,
  Map<String, ActorModel> actors = const {},
  Map<String, TrackModel> tracks = const {},
  dynamic onContainerItemsReorder,
  bool isEditingContainer = false,
  bool isInSlideEditor = false,
  bool isHighlighted = false,
  dynamic onItemClick,
  Set<String> selectedContainerIds = const <String>{},
  EdgeInsets elementPadding = EdgeInsets.zero,
}) {
  final withPadding = (Widget child) => Padding(
        padding: elementPadding,
        child: child,
      );

  if (element is ContainerElementModel) {
    int index = 0;

    return withPadding(ContainerElement(
      isEditing: isEditingContainer,
      showBorder: isInSlideEditor,
      showHighlight: isHighlighted,
      mainAxisAlignment: element.mainAxisAlignment,
      crossAxisAlignment: element.crossAxisAlignment,
      runAlignment: element.runAlignment,
      allowWrap: element.wrapEnabled,
      axis: element.axis,
      onOrderChanged: (id, oldIndex, newIndex) =>
          onContainerItemsReorder?.call(id, oldIndex, newIndex),
      onItemClick: onItemClick,
      items: element.children
          .where((child) => _shouldBuild(child, selectedPreset))
          .map((child) {
        return ContainerItem(
          dragId: child.uid,
          index: index++,
          selected: selectedContainerIds != null &&
              selectedContainerIds.contains(child.uid),
          size: Size(child.width, child.height),
          child: _buildChild(
            element: child.child,
            selectedPreset: selectedPreset,
            actors: actors,
            tracks: tracks,
            elementPadding: EdgeInsets.fromLTRB(
                child.leftPadding?.toDouble() ?? 0,
                child.topPadding?.toDouble() ?? 0,
                child.rightPadding?.toDouble() ?? 0,
                child.bottomPadding?.toDouble() ?? 0),
          ),
        );
      }).toList(),
    ));
  }

  if (element is GroupElementModel) {
    return MultiChildCanvasItem(
      padding: elementPadding,
      children: element.children.map(
        (child) {
          return LayoutBlock(
            id: child.uid,
            xPos: child.xPos,
            yPos: child.yPos,
            width: child.width,
            height: child.height,
            rotation: child.rotation,
            child: _buildChild(
                element: child.child,
                actors: actors,
                tracks: tracks,
                selectedPreset: selectedPreset),
          );
        },
      ).toList(),
    );
  }

  if (element is HeadshotElementModel) {
    final actor = _getAssignedActor(element, selectedPreset, actors);

    if (tracks == null) {
      return withPadding(NoTrackFallback());
    }

    final track = tracks[element.trackId];

    if (track == null) {
      return withPadding(NoTrackFallback());
    }

    if (actor == null) {
      return withPadding(NoActorFallback(
        trackTitle: track.title,
      ));
    }

    if (actor.headshotRef == null || actor.headshotRef.uid.isEmpty) {
      return withPadding(NoHeadshotFallback(
        trackTitle: track.title,
      ));
    }

    return withPadding(ImageElement(
      file: Storage.instance.getHeadshotFile(actor.headshotRef),
    ));
  }

  if (element is TextElementModel) {
    String text = _lookupText(element, selectedPreset, actors, tracks);
    return withPadding(
      TextElement(
        text: text,
        style: TextElementStyle(
            alignment: element.alignment,
            color: element.color,
            fontFamily: element.fontFamily,
            fontSize: element.fontSize,
            bold: element.bold,
            italics: element.italics,
            underline: element.underline),
      ),
    );
  }

  if (element is ShapeElementModel) {
    return withPadding(ShapeElement(
      type: element.type,
      fill: element.fill,
      lineColor: element.lineColor,
      lineWeight: element.lineWeight,
    ));
  }

  return SizedBox.fromSize(size: Size.zero);
}

bool _shouldBuild(LayoutElementModel element, PresetModel selectedPreset) {
  if (selectedPreset == null) {
    return true;
  }

  final child = element.child;
  if (child.canConditionallyRender == false) {
    return true;
  }

  if (child is GroupElementModel) {
    final canAllChildrenConditionallyRender = child.children
        .every((item) => item.child.canConditionallyRender == true);

    if (canAllChildrenConditionallyRender == false) {
      return true;
    }

    final shouldBuild =
        child.children.every((item) => _shouldBuild(item, selectedPreset));

    return shouldBuild;
  }

  if (child is HeadshotElementModel) {
    return selectedPreset?.assignments[child.trackId] != ActorModel.cutTrackId;
  }

  if (child is TrackElementModel) {
    return selectedPreset?.assignments[child.trackId] != ActorModel.cutTrackId;
  }

  if (child is ActorElementModel) {
    return selectedPreset?.assignments[child.trackId] != ActorModel.cutTrackId;
  }


  return true;
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
