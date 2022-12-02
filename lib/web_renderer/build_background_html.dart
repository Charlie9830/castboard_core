import 'dart:ui';

import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/elements/background/get_background.dart';
import 'package:castboard_core/web_renderer/html_element_mapping.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/utils/css_helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';

Element buildBackgroundHtml({
  required String urlPrefix,
  required Map<String, SlideModel> slides,
  required String slideId,
  required Size slideSize,
}) {
  final currentSlide = slides[slideId];

  final String backgroundBaseStyle = '''
position: absolute;
top: 0px;
left: 0px;
width: ${slideSize.width}px;
height: ${slideSize.height}px;
z-index: -1000;
''';

  if (currentSlide == null) {
    return Element.html('''
    <div 
      ${HTMLElementMapping.backgroundElement}
      style="
      $backgroundBaseStyle
      background-color: #FFF;
      "/>
    ''');
  }

  final slideBackground = getSlideBackground(slides, currentSlide);

  if (slideBackground.imageRef == const ImageRef.none()) {
    // Simple Color Background
    return Element.html('''
    <div 
    ${HTMLElementMapping.backgroundElement}
    style="
    $backgroundBaseStyle
    background-color: ${convertToCssColor(slideBackground.color)};
    "
    />''');
  } else {
    // Adding the crossoriginAttr allows img src to be parsed correctly by the browser in debug mode.
    // Otherwise the browser will prefix the Web page address, which may be getting served from the
    // development server, not performer itself.
    final crossoriginAttr = kDebugMode ? 'crossorigin' : '';

    // Image Background.
    return Element.html('''
    <img 
    $crossoriginAttr
    src="$urlPrefix/backgrounds/${slideBackground.imageRef.basename}"
    ${HTMLElementMapping.backgroundElement}
    style="$backgroundBaseStyle"
/>''');
  }
}
