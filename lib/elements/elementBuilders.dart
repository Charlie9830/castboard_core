import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/elements/ActorElementModel.dart';
import 'package:castboard_core/elements/ContainerElement.dart';
import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/elements/ContainerItem.dart';
import 'package:castboard_core/elements/ImageElement.dart';
import 'package:castboard_core/elements/ImageElementModel.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/layout-canvas/MultiChildCanvasItem.dart';
import 'package:castboard_core/elements/GroupElementModel.dart';
import 'package:castboard_core/elements/HeadshotElementModel.dart';
import 'package:castboard_core/elements/HeadshotFallback.dart';
import 'package:castboard_core/elements/ShapeElement.dart';
import 'package:castboard_core/elements/ShapeElementModel.dart';
import 'package:castboard_core/elements/TextElement.dart';
import 'package:castboard_core/elements/TextElementModel.dart';
import 'package:castboard_core/elements/TrackElementModel.dart';
import 'package:castboard_core/layout-canvas/LayoutBlock.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/CastChangeModel.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/storage/Storage.dart';
import 'package:flutter/material.dart';

typedef OnContainerItemsReorder = void Function(
    String? containerId, String itemId, int oldIndex, int newIndex);

typedef OnContainerItemEvict = void Function(String itemId);

Map<String, LayoutBlock> buildElements({
  SlideModel? slide,
  CastChangeModel? castChange,
  Map<ActorRef, ActorModel>? actors,
  Map<String, TrackRef> trackRefsByName = const {},
  Map<TrackRef, TrackModel>? tracks,
  OnContainerItemsReorder? onContainerItemsReorder,
  String editingContainerId = '',
  String highlightedContainerId = '',
  bool isInSlideEditor = false,
  dynamic onContainerItemClick,
  Set<String>? selectedContainerItemIds,
  OnContainerItemEvict? onContainerItemEvict,
}) {
  final Map<String, LayoutElementModel> elements =
      slide?.elements ?? <String, LayoutElementModel>{};

  return Map<String, LayoutBlock>.fromEntries(
    elements.values.where((element) => _shouldBuild(element, castChange)).map(
      (element) {
        final id = element.uid;
        final isEditingContainer = id == editingContainerId;
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
              castChange: castChange,
              actors: actors,
              trackRefsByName: trackRefsByName,
              tracks: tracks,
              elementPadding: _buildEdgeInsets(element),
              isInSlideEditor: isInSlideEditor,
              isEditingContainer: isEditingContainer,
              isHighlighted: isEditingContainer || highlightedContainerId == id,
              onContainerItemsReorder: (itemId, oldIndex, newIndex) =>
                  onContainerItemsReorder?.call(id, itemId, oldIndex, newIndex),
              onItemClick: onContainerItemClick,
              selectedContainerIds: selectedContainerItemIds,
              onItemEvict: onContainerItemEvict,
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildChild({
  LayoutElementChild? element,
  CastChangeModel? castChange,
  Map<ActorRef, ActorModel>? actors = const {},
  required Map<String, TrackRef> trackRefsByName,
  Map<TrackRef, TrackModel>? tracks = const {},
  dynamic onContainerItemsReorder,
  bool isEditingContainer = false,
  bool isInSlideEditor = false,
  bool isHighlighted = false,
  dynamic onItemClick,
  OnContainerItemEvict? onItemEvict,
  Set<String>? selectedContainerIds = const <String>{},
  EdgeInsets elementPadding = EdgeInsets.zero,
}) {
  withPadding(Widget child) => Padding(
        padding: elementPadding,
        child: child,
      );

  if (element is ContainerElementModel) {
    int index = 0;

    final containerItems =
        element.runLoading == ContainerRunLoading.bottomOrRightHeavy
            ? element.children.reversed
            : element.children;

    return withPadding(ContainerElement(
      isEditing: isEditingContainer,
      showBorder: isInSlideEditor,
      showHighlight: isHighlighted,
      mainAxisAlignment: element.mainAxisAlignment,
      crossAxisAlignment: element.crossAxisAlignment,
      runAlignment: element.runAlignment,
      runLoading: element.runLoading,
      allowWrap: element.wrapEnabled,
      axis: element.axis,
      onOrderChanged: (id, oldIndex, newIndex) =>
          onContainerItemsReorder?.call(id, oldIndex, newIndex),
      onItemClick: onItemClick,
      onItemEvict: onItemEvict,
      items: containerItems
          .where((child) => _shouldBuild(child, castChange))
          .map((child) {
        return ContainerItem(
          dragId: child.uid,
          index: index++,
          selected: selectedContainerIds != null &&
              selectedContainerIds.contains(child.uid),
          size: Size(child.width, child.height),
          child: _buildChild(
            element: child.child,
            castChange: castChange,
            actors: actors,
            trackRefsByName: trackRefsByName,
            tracks: tracks,
            elementPadding: _buildEdgeInsets(child),
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
                trackRefsByName: trackRefsByName,
                tracks: tracks,
                castChange: castChange),
          );
        },
      ).toList(),
    );
  }

  if (element is HeadshotElementModel) {
    if (tracks == null) {
      return withPadding(const HeadshotFallback(
        reason: HeadshotFallbackReason.noTrack,
      ));
    }

    final track = tracks[element.trackRef];

    if (track == null) {
      return withPadding(
          const HeadshotFallback(reason: HeadshotFallbackReason.noTrack));
    }

    final actor = _getAssignedActor(element, castChange, actors);

    if (actor == null) {
      return withPadding(
          const HeadshotFallback(reason: HeadshotFallbackReason.noActor));
    }

    if (actor.headshotRef.uid!.isEmpty) {
      return withPadding(const HeadshotFallback(
        reason: HeadshotFallbackReason.noPhoto,
      ));
    }

    return withPadding(
      ImageElement(
        file: Storage.instance.getHeadshotFile(actor.headshotRef),
      ),
    );
  }

  if (element is TextElementModel) {
    String? text =
        _lookupText(element, castChange, actors, tracks, trackRefsByName);

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
    return GestureDetector(
      onTap: () => print('Shape Element Primary'),
      onSecondaryTap: () => print('Shape Element Secondary'),
      child: withPadding(ShapeElement(
        type: element.type,
        fill: element.fill,
        lineColor: element.lineColor,
        lineWeight: element.lineWeight,
      )),
    );
  }

  if (element is ImageElementModel) {
    return withPadding(ImageElement(
      file: Storage.instance.getImageFile(element.ref),
    ));
  }

  return SizedBox.fromSize(size: Size.zero);
}

EdgeInsets _buildEdgeInsets(LayoutElementModel element) {
  return EdgeInsets.fromLTRB(
    element.leftPadding.toDouble(),
    element.topPadding.toDouble(),
    element.rightPadding.toDouble(),
    element.bottomPadding.toDouble(),
  );
}

bool _shouldBuild(LayoutElementModel element, CastChangeModel? castChange) {
  if (castChange == null) {
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
        child.children.every((item) => _shouldBuild(item, castChange));

    return shouldBuild;
  }

  if (child is HeadshotElementModel) {
    return !castChange.isCut(child.trackRef);
  }

  if (child is TrackElementModel) {
    return !castChange.isCut(child.trackRef);
  }

  if (child is ActorElementModel) {
    return !castChange.isCut(child.trackRef);
  }

  return true;
}

String? _lookupText(
  TextElementModel element,
  CastChangeModel? castChange,
  Map<ActorRef, ActorModel>? actors,
  Map<TrackRef, TrackModel>? tracks,
  Map<String, TrackRef> trackRefsByName,
) {
  if (element is ActorElementModel) {
    return _lookupActorName(element.trackRef, castChange, actors, tracks);
  }

  if (element is TrackElementModel) {
    return _lookupTrackName(element.trackRef, castChange, actors, tracks);
  }

  if (element.needsInterpolation == true) {
    if (TextElementModel.matchInterpolationRegex.hasMatch(element.text) ==
        false) return 'NOT FOUND';

    String interpolated = element.text
        .replaceAllMapped(TextElementModel.matchInterpolationRegex, (match) {
      final matchText = match.group(0);

      if (matchText == null) return 'NOT FOUND';

      final trackName = matchText.replaceAll(
          TextElementModel.matchInterpolationOperatorsRegex, '');

      final trackRef = trackRefsByName[trackName];

      if (trackRef == null) {
        return 'NOT FOUND';
      }

      return _lookupActorName(trackRef, castChange, actors, tracks) ??
          'NOT FOUND';
    });

    return interpolated;
  }

  return element.text;
}

String _lookupTrackName(TrackRef trackRef, CastChangeModel? castChange,
    Map<ActorRef, ActorModel>? actors, Map<TrackRef, TrackModel>? tracks) {
  if (trackRef == const TrackRef.blank() ||
      tracks == null ||
      tracks.containsKey(trackRef) == false) {
    return 'Unassigned';
  }

  return tracks[trackRef]?.title ?? 'Untitled track';
}

String? _lookupActorName(TrackRef trackRef, CastChangeModel? castChange,
    Map<ActorRef, ActorModel>? actors, Map<TrackRef, TrackModel>? tracks) {
  if (trackRef == const TrackRef.blank() ||
      tracks == null ||
      tracks.containsKey(trackRef) == false) {
    return 'Unassigned';
  }

  if (castChange == null) {
    return "Artist's name";
  }

  if (castChange.hasAssignment(trackRef) == false) {
    return "Artist's name";
  }

  final actor = actors![castChange.actorAt(trackRef)!];
  if (actor == null) {
    return "Artist missing";
  }

  return actor.name;
}

ActorModel? _getAssignedActor(HeadshotElementModel element,
    CastChangeModel? castChange, Map<ActorRef, ActorModel>? actors) {
  if (castChange == null) {
    return null;
  }

  final actorRef = castChange.actorAt(element.trackRef);

  if (actorRef == null ||
      actorRef.isBlank ||
      actors!.containsKey(actorRef) == false) {
    return null;
  }

  return actors[actorRef];
}
