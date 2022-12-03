import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/elements/ActorElementModel.dart';
import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/elements/ImageElementModel.dart';
import 'package:castboard_core/elements/ShapeElementModel.dart';
import 'package:castboard_core/utils/get_fitted_render_scale.dart';
import 'package:castboard_core/web_renderer/html_element_mapping.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/elements/GroupElementModel.dart';
import 'package:castboard_core/elements/HeadshotElementModel.dart';
import 'package:castboard_core/elements/TextElementModel.dart';
import 'package:castboard_core/elements/TrackElementModel.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/CastChangeModel.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/utils/css_helpers.dart';
import 'package:castboard_core/utils/line_breaking.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

dom.Element buildSlideElementsHtml({
  required String urlPrefix,
  SlideModel? slide,
  CastChangeModel? castChange,
  Map<ActorRef, ActorModel> actors = const {},
  Map<String, TrackRef> trackRefsByName = const {},
  Map<TrackRef, TrackModel> tracks = const {},
}) {
  // Build Element Canvas
  final elementCanvas = dom.Element.html('''
  <div ${HTMLElementMapping.elementCanvas}/>
  ''');

  if (slide == null) {
    return elementCanvas;
  }

  for (final element in slide.elements.values
      .where((element) => _shouldBuild(element, castChange))) {
    elementCanvas.append(dom.Element.html(_buildElement(
        urlPrefix: urlPrefix,
        element: element,
        trackRefsByName: trackRefsByName,
        actors: actors,
        castChange: castChange,
        tracks: tracks)));
  }

  return elementCanvas;
}

String _buildElement({
  required String urlPrefix,
  required LayoutElementModel element,
  CastChangeModel? castChange,
  Map<ActorRef, ActorModel> actors = const {},
  required Map<String, TrackRef> trackRefsByName,
  Map<TrackRef, TrackModel> tracks = const {},
  bool ignorePosition = false,
}) {
  return '''
  <div style="
  position: ${ignorePosition ? 'relative' : 'absolute'};
  left: ${ignorePosition ? 0 : element.xPos}px;
  top: ${ignorePosition ? 0 : element.yPos}px;
  width: ${element.width}px;
  height: ${element.height}px;
  transform: rotate(${element.rotation}rad);">
              ${_buildChild(urlPrefix: urlPrefix, element: element.child, parent: element, trackRefsByName: trackRefsByName, actors: actors, castChange: castChange, tracks: tracks)}
            </div>
''';
}

String _buildChild({
  required String urlPrefix,
  required LayoutElementChild element,
  required LayoutElementModel parent,
  CastChangeModel? castChange,
  Map<ActorRef, ActorModel> actors = const {},
  required Map<String, TrackRef> trackRefsByName,
  Map<TrackRef, TrackModel> tracks = const {},
}) {
  // Group Element.
  if (element is GroupElementModel) {
    final innerHtml = element.children.values
        .map((child) => _buildElement(
            urlPrefix: urlPrefix,
            element: child,
            trackRefsByName: trackRefsByName,
            actors: actors,
            tracks: tracks,
            castChange: castChange))
        .join('\n');

    return '''
    <div ${HTMLElementMapping.groupElement}>
      $innerHtml
    </div>
''';
  }

  // Container Element
  if (element is ContainerElementModel) {
    final containerItems =
        (element.runLoading == ContainerRunLoading.bottomOrRightHeavy
                ? element.children.values.toList().reversed
                : element.children.values.toList())
            .where((item) => _shouldBuild(item, castChange));

    // Delegate to fetch the Item Width or Height depending on the provided axis.
    double getItemLength(LayoutElementModel item) =>
        element.axis == Axis.horizontal ? item.size.width : item.size.height;

    // Use the 'Minimum Raggedness Divide and Conquer' algorithm to determine how to layout each item into run.
    final layoutIndexes = MinimumRaggedness.divide(
        containerItems.map((item) => getItemLength(item)).toList(),
        element.axis == Axis.horizontal ? parent.width : parent.height);

    // Take the List<List<int>> type returned by the layout algorithm and convert that to widgets.
    final children = layoutIndexes
        .map((run) => run.map((index) {
              final item = containerItems.elementAt(index);

              return _buildElement(
                  urlPrefix: urlPrefix,
                  ignorePosition: true,
                  element: item,
                  actors: actors,
                  castChange: castChange,
                  tracks: tracks,
                  trackRefsByName: trackRefsByName);
            }).toList())
        .toList();

    return _buildContainerElement(
        mainAxisAlignment: element.mainAxisAlignment,
        crossAxisAlignment: element.crossAxisAlignment,
        runAlignment: element.runAlignment,
        wrapEnabled: element.wrapEnabled,
        axis: element.axis,
        children: children);
  }

  // Text Element
  if (element is TextElementModel) {
    String text =
        _lookupText(element, castChange, actors, tracks, trackRefsByName) ?? '';

    return '''
      <div ${HTMLElementMapping.textAligner} cb-element="text-aligner"
      style="
      height: 100%;
      width: 100%;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: stretch;
      ">
      <div ${HTMLElementMapping.textElement} style="${element.cssStyle}">
      ${text.replaceAll('\n', '<br/>')}
      </div>
      </div>
    ''';
  }

  // Image Element
  if (element is ImageElementModel) {
    return _buildImageHtml('$urlPrefix/images/', element.ref);
  }

  // Headshot Element
  if (element is HeadshotElementModel) {
    final track = tracks[element.trackRef];

    if (track == null) {
      return '<div/>';
    }

    final actor = _getAssignedActor(element, castChange, actors);

    if (actor == null) {
      return '<div/>';
    }

    if (actor.headshotRef.uid.isEmpty) {
      return '<div/>';
    }

    return _buildImageHtml('$urlPrefix/headshots/', actor.headshotRef);
  }

  if (element is ShapeElementModel) {
    final width = element.type == ShapeElementType.circle
        ? '${_smallerOf(parent.width, parent.height)}px'
        : '100%';
    final height = element.type == ShapeElementType.circle
        ? '${_smallerOf(parent.width, parent.height)}px'
        : '100%';

    return '''
<div ${HTMLElementMapping.shapeElement} style="
width: $width;
height: $height;
border-radius: ${element.type == ShapeElementType.circle ? '50%' : '0%'};
background-color: ${convertToCssColor(element.fill)};
border-color: ${convertToCssColor(element.lineColor)};
border-width: ${element.lineWeight}px;
border-style: solid;
"/>
''';
  }

  return '''
  <div>
    Unimplemented
  </div>
''';
}

String _buildImageHtml(String sourcePrefix, ImageRef imageRef) {
  // Adding the crossoriginAttr allows img src to be parsed correctly by the browser in debug mode.
  // Otherwise the browser will prefix the Web page address, which may be getting served from the
  // development server, not performer itself.
  const crossoriginAtrr = kDebugMode ? 'crossorigin' : '';

  return '''
  <img $crossoriginAtrr ${HTMLElementMapping.imageElement}
  style="height: 100%; width: 100%; object-fit: contain" src="$sourcePrefix${imageRef.basename}"/>
  ''';
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

String _buildContainerElement({
  required MainAxisAlignment mainAxisAlignment,
  required CrossAxisAlignment crossAxisAlignment,
  required WrapAlignment runAlignment,
  required bool wrapEnabled,
  required Axis axis,
  required List<List<String>> children,
}) {
  if (wrapEnabled == false) {
    if (axis == Axis.horizontal) {
      return _buildHorizontalContainer(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children.expand((i) => i).toList());
    } else {
      return _buildVerticalContainer(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children.expand((i) => i).toList());
    }
  }

  if (axis == Axis.horizontal) {
    return '''
  <div ${HTMLElementMapping.containerElement}
  style="width: 100%; height: 100%; display: flex; flex-direction: column; justify-content: ${convertRunAlignmentToJustifyContent(runAlignment)}">
    ${children.map((run) => _buildHorizontalContainer(mainAxisAlignment: mainAxisAlignment, crossAxisAlignment: crossAxisAlignment, children: run)).join('\n')}
  </div>
''';
  } else {
    return '''
  <div ${HTMLElementMapping.containerElement}
  style="width: 100%; height: 100%; display: flex; flex-direction: row; justify-content: ${convertRunAlignmentToJustifyContent(runAlignment)}">
    ${children.map((run) => _buildVerticalContainer(mainAxisAlignment: mainAxisAlignment, crossAxisAlignment: crossAxisAlignment, children: run)).join('\n')}
  </div>
''';
  }
}

String _buildHorizontalContainer(
    {required MainAxisAlignment mainAxisAlignment,
    required CrossAxisAlignment crossAxisAlignment,
    required List<String> children}) {
  // Build the children using a dom.Element otherwise we get weird HTML behaviour.
  final runChildren = children.map((item) => dom.Element.html(item).outerHtml);

  return '''
  <div ${HTMLElementMapping.horizontalLayoutContainer}
  style="
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: row;
  justify-content: ${convertToJustifyContent(mainAxisAlignment)};
  align-items: ${convertToAlignItems(crossAxisAlignment)};
  ">
  ${runChildren.join('\n')}
  </div>
''';
}

String _buildVerticalContainer(
    {required MainAxisAlignment mainAxisAlignment,
    required CrossAxisAlignment crossAxisAlignment,
    required List<String> children}) {
  // Build the children using a dom.Element otherwise we get weird HTML behaviour.
  final runChildren = children.map((item) => dom.Element.html(item).outerHtml);

  return '''
  <div ${HTMLElementMapping.horizontalLayoutContainer}
  style="
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: ${convertToJustifyContent(mainAxisAlignment)};
  align-items: ${convertToAlignItems(crossAxisAlignment)};
  ">
  ${runChildren.join('\n')}
  </div>
''';
}

double _smallerOf(double a, double b) {
  if (a > b) {
    return b;
  } else {
    return a;
  }
}
