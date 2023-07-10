import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/elements/ContainerElementModel.dart';
import 'package:castboard_core/elements/ImageElementModel.dart';
import 'package:castboard_core/elements/ShapeElementModel.dart';
import 'package:castboard_core/elements/get_assigned_actor.dart';
import 'package:castboard_core/elements/lookup_text.dart';
import 'package:castboard_core/elements/should_build_element.dart';
import 'package:castboard_core/web_renderer/dom_element_factory.dart';
import 'package:castboard_core/web_renderer/html_element_mapping.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/elements/GroupElementModel.dart';
import 'package:castboard_core/elements/HeadshotElementModel.dart';
import 'package:castboard_core/elements/TextElementModel.dart';
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
  bool showDemoDisclaimer = false,
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
      .where((element) => shouldBuildElement(element, castChange))) {
    elementCanvas.append(dom.Element.html(_buildElement(
        urlPrefix: urlPrefix,
        element: element,
        trackRefsByName: trackRefsByName,
        actors: actors,
        castChange: castChange,
        tracks: tracks)));
  }

  if (showDemoDisclaimer) {
    elementCanvas.append(dom.Element.html(_buildDisclaimerOverlay()));
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
  final domElement = DomElementFactory.buildDiv(style: '''
  position: ${ignorePosition ? 'relative' : 'absolute'};
  left: ${ignorePosition ? 0 : element.xPos}px;
  top: ${ignorePosition ? 0 : element.yPos}px;
  width: ${_computeAbsoluteWidth(element)};
  height: ${_computeAbsoluteHeight(element)};
  transform: rotate(${element.rotation}rad);
''');

  domElement.append(
    dom.Element.html(
      _buildChild(
          urlPrefix: urlPrefix,
          element: element.child,
          parent: element,
          trackRefsByName: trackRefsByName,
          actors: actors,
          castChange: castChange,
          tracks: tracks),
    ),
  );

  return domElement.outerHtml;
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
    <div ${HTMLElementMapping.groupElement} style="position: relative">
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
            .where((item) => shouldBuildElement(item, castChange));

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
        runLoading: element.runLoading,
        axis: element.axis,
        children: children);
  }

  // Text Element
  if (element is TextElementModel) {
    String text =
        lookupText(element, castChange, actors, tracks, trackRefsByName) ?? '';

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

    final actor = getAssignedActor(element, castChange, actors);

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

String _buildContainerElement({
  required MainAxisAlignment mainAxisAlignment,
  required CrossAxisAlignment crossAxisAlignment,
  required WrapAlignment runAlignment,
  required bool wrapEnabled,
  required ContainerRunLoading runLoading,
  required Axis axis,
  required List<List<String>> children,
}) {
  if (wrapEnabled == false) {
    if (axis == Axis.horizontal) {
      return _buildHorizontalContainer(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          runLoading: runLoading,
          children: children.expand((i) => i).toList());
    } else {
      return _buildVerticalContainer(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          runLoading: runLoading,
          children: children.expand((i) => i).toList());
    }
  }

  if (axis == Axis.horizontal) {
    // Horizontal Wrapped Container
    return '''
  <div ${HTMLElementMapping.containerElement}
  style="width: 100%; height: 100%; display: flex; flex-direction: ${runLoading == ContainerRunLoading.topOrLeftHeavy ? 'column' : 'column-reverse'}; justify-content: ${convertRunAlignmentToJustifyContent(runAlignment)}">
    ${children.map((run) => _buildHorizontalContainer(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: CrossAxisAlignment
                  .center, // CrossAxisAlignment locked to Center when Wrapping.
              runLoading: runLoading,
              children: run,
            )).join('\n')}
  </div>
''';
  } else {
    // Vertical Wrapped Container
    return '''
  <div ${HTMLElementMapping.containerElement}
  style="width: 100%; height: 100%; display: flex; flex-direction: ${runLoading == ContainerRunLoading.topOrLeftHeavy ? 'row' : 'row-reverse'}; justify-content: ${convertRunAlignmentToJustifyContent(runAlignment)}">
    ${children.map((run) => _buildVerticalContainer(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: CrossAxisAlignment
                  .center, // CrossAxisAlignment locked to Center when Wrapping.
              runLoading: runLoading,
              children: run,
            )).join('\n')}
  </div>
''';
  }
}

String _buildHorizontalContainer(
    {required MainAxisAlignment mainAxisAlignment,
    required CrossAxisAlignment crossAxisAlignment,
    required ContainerRunLoading runLoading,
    required List<String> children}) {
  // Build the children using a dom.Element otherwise we get weird HTML behaviour.
  final runChildren = children.map((item) => dom.Element.html(item).outerHtml);

  return '''
  <div ${HTMLElementMapping.horizontalLayoutContainer}
  style="
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: ${runLoading == ContainerRunLoading.bottomOrRightHeavy ? 'row-reverse' : 'row'};
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
    required ContainerRunLoading runLoading,
    required List<String> children}) {
  // Build the children using a dom.Element otherwise we get weird HTML behaviour.
  final runChildren = children.map((item) => dom.Element.html(item).outerHtml);

  return '''
  <div ${HTMLElementMapping.horizontalLayoutContainer}
  style="
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: ${runLoading == ContainerRunLoading.bottomOrRightHeavy ? 'column-reverse' : 'column'};
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

String _computeAbsoluteWidth(LayoutElementModel element) {
  if (element.child is ShapeElementModel) {
    // CSS Applies the border and overflows it over the Right and bottom edges, as opposed to Flutter that applies it to all
    // sides equally. Therefore we need to adjust the final position of the shape if it has a lineweight value.
    final lineWeight = (element.child as ShapeElementModel).lineWeight;

    return '${element.width - (lineWeight * 2)}px';
  }

  return '${element.width}px';
}

String _computeAbsoluteHeight(LayoutElementModel element) {
  if (element.child is ShapeElementModel) {
    // CSS Applies the border and overflows it over the Right and bottom edges, as opposed to Flutter that applies it to all
    // sides equally. Therefore we need to adjust the final position of the shape if it has a lineweight value.
    final lineWeight = (element.child as ShapeElementModel).lineWeight;

    return '${element.height - (lineWeight * 2)}px';
  }

  return '${element.height}px';
}

String _buildDisclaimerOverlay() {
  final element = DomElementFactory.buildDiv(style: '''
position: absolute;
color: rgba(255,255,255,0.75);
width: 1920px;
height: 1080px;
display: flex;
font-family: Poppins;
flex-direction: row;
justify-content: center;
font-size: 120pt;
align-items: center;
transform: rotate(45deg);
''');

  element.text = 'Demonstration File';

  return element.outerHtml;
}
