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
import 'package:castboard_core/layout-canvas/element_ref.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/CastChangeModel.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/storage/Storage.dart';
import 'package:flutter/material.dart';

typedef OnContainerItemsReorder = void Function(
    ElementRef itemId, int oldIndex, int newIndex);

typedef OnContainerItemDoubleClick = void Function(
    ElementRef itemId, PointerEvent event);

typedef OpenContainerItemBuilder = Widget Function(
    BuildContext context, ElementRef itemId);

Map<ElementRef, LayoutBlock> buildElements({
  BuildContext? context, // Context is only required by the Slide Editor.
  Map<ElementRef, LayoutElementModel> elements = const {},
  ElementRef openElementId = const ElementRef.none(),
  List<String> reference = const [],
  CastChangeModel? castChange,
  Map<ActorRef, ActorModel> actors = const {},
  Map<String, TrackRef> trackRefsByName = const {},
  Map<TrackRef, TrackModel> tracks = const {},
  OnContainerItemsReorder? onContainerItemsReorder,
  ElementRef highlightedContainerId = const ElementRef.none(),
  bool isInSlideEditor = false,
}) {
  return Map<ElementRef, LayoutBlock>.fromEntries(
    elements.values.where((element) => _shouldBuild(element, castChange)).map(
      (element) {
        final id = element.uid;
        final isEditingContainer = id == openElementId;
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
              parentReference: id,
              context: context,
              element: element.child,
              castChange: castChange,
              actors: actors,
              trackRefsByName: trackRefsByName,
              tracks: tracks,
              elementPadding: _buildEdgeInsets(element),
              isInSlideEditor: isInSlideEditor,
              isEditingContainer: isEditingContainer,
              isHighlighted: isEditingContainer || highlightedContainerId == id,
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildChild({
  required ElementRef parentReference,
  ElementRef openElementId = const ElementRef.none(),
  BuildContext? context, // Context is only required by the Slide Editor.
  LayoutElementChild? element,
  CastChangeModel? castChange,
  Map<ActorRef, ActorModel> actors = const {},
  required Map<String, TrackRef> trackRefsByName,
  Map<TrackRef, TrackModel> tracks = const {},
  OnContainerItemsReorder? onContainerItemsReorder,
  bool isEditingContainer = false,
  bool isInSlideEditor = false,
  bool isHighlighted = false,
  EdgeInsets elementPadding = EdgeInsets.zero,
}) {
  withPadding(Widget child) => Padding(
        padding: elementPadding,
        child: child,
      );

  if (element is ContainerElementModel) {
    return buildContainer(
        isEditingContainer: isEditingContainer,
        isInSlideEditor: isInSlideEditor,
        isHighlighted: isHighlighted,
        element: element,
        castChange: castChange,
        openElementId: openElementId,
        context: context,
        actors: actors,
        trackRefsByName: trackRefsByName,
        tracks: tracks);
  }

  if (element is GroupElementModel) {
    return MultiChildCanvasItem(
      padding: elementPadding,
      children: element.children.values.map(
        (child) {
          final id = child.uid;
          return LayoutBlock(
            id: id,
            xPos: child.xPos,
            yPos: child.yPos,
            width: child.width,
            height: child.height,
            rotation: child.rotation,
            child: _buildChild(
              parentReference: id,
              element: child.child,
              actors: actors,
              trackRefsByName: trackRefsByName,
              tracks: tracks,
              castChange: castChange,
            ),
          );
        },
      ).toList(),
    );
  }

  if (element is HeadshotElementModel) {
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
          underline: element.underline,
          shadowBlurRadius: element.shadowBlurRadius,
          shadowColor: element.shadowColor,
          shadowXOffset: element.shadowXOffset,
          shadowYOffset: element.shadowYOffset,
        ),
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

  if (element is ImageElementModel) {
    return withPadding(ImageElement(
      file: Storage.instance.getImageFile(element.ref),
    ));
  }

  return SizedBox.fromSize(size: Size.zero);
}

Widget buildContainer({
  required bool isEditingContainer,
  required bool isInSlideEditor,
  required bool isHighlighted,
  required ContainerElementModel element,
  OnContainerItemsReorder? onItemReorder,
  OnItemActionCallback? onItemClick,
  OnItemActionCallback? onItemEvict,
  OnItemActionCallback? onItemCopy,
  OnItemActionCallback? onItemPaste,
  OnItemActionCallback? onItemDelete,
  OnItemActionCallback? onItemEdit,
  OnItemDoubleClickCallback? onContainerItemDoubleClick,
  CastChangeModel? castChange,
  Set<ElementRef> selectedElements = const {},
  required ElementRef openElementId,
  OpenContainerItemBuilder? openContainerItemBuilder,
  BuildContext? context,
  required Map<ActorRef, ActorModel> actors,
  required Map<String, TrackRef> trackRefsByName,
  required Map<TrackRef, TrackModel> tracks,
  bool deferHitTestingToChildren = false,
}) {
  final containerItems =
      element.runLoading == ContainerRunLoading.bottomOrRightHeavy
          ? element.children.values.toList().reversed
          : element.children.values.toList();
  int index = 0;

  return ContainerElement(
    isEditing: isEditingContainer,
    showBorder: isInSlideEditor,
    showHighlight: isHighlighted,
    mainAxisAlignment: element.mainAxisAlignment,
    crossAxisAlignment: element.crossAxisAlignment,
    runAlignment: element.runAlignment,
    runLoading: element.runLoading,
    allowWrap: element.wrapEnabled,
    axis: element.axis,
    onItemClick: onItemClick,
    onItemEvict: onItemEvict,
    onItemCopy: onItemCopy,
    onItemPaste: onItemPaste,
    onItemDelete: onItemDelete,
    onItemDoubleClick: onContainerItemDoubleClick,
    onItemEdit: onItemEdit,
    onOrderChanged: onItemReorder,
    items: containerItems
        .where((child) => _shouldBuild(child, castChange))
        .map((child) {
      final id = child.uid;

      final deferToOpenItemBuilder =
          id == openElementId && openContainerItemBuilder != null;
      return ContainerItem(
        id: id,
        index: index++,
        selected: selectedElements.contains(id),
        size: Size(child.width, child.height),
        deferHitTestingToChild: deferToOpenItemBuilder,
        child: deferToOpenItemBuilder == true
            ? _callContainerItemBuilder(context, id, openContainerItemBuilder!)
            : _buildChild(
                parentReference: id,
                element: child.child,
                castChange: castChange,
                actors: actors,
                trackRefsByName: trackRefsByName,
                tracks: tracks,
                elementPadding: _buildEdgeInsets(child),
              ),
      );
    }).toList(),
  );
}

Widget _callContainerItemBuilder(BuildContext? context, ElementRef itemId,
    OpenContainerItemBuilder builder) {
  if (context == null) {
    throw AssertionError(
        'The optional context parameter must be provided when using the containerItemBuilder.');
  }

  return builder(context, itemId);
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
    final canAllChildrenConditionallyRender = child.children.values
        .every((item) => item.child.canConditionallyRender == true);

    if (canAllChildrenConditionallyRender == false) {
      return true;
    }

    final shouldBuild =
        child.children.values.every((item) => _shouldBuild(item, castChange));

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
