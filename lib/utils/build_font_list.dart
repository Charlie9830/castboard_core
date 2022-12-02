import 'package:castboard_core/elements/TextElementModel.dart';
import 'package:castboard_core/elements/multi_child_element_model.dart';
import 'package:castboard_core/models/LayoutElementModel.dart';
import 'package:castboard_core/models/SlideModel.dart';

List<String> buildFontList(List<SlideModel> slides) {
  final textElements = slides.expand<TextElementModel>((slide) {
    return slide.elements.values.expand((element) {
      return _extractTextElements(element);
    });
  });

  final usedFontFamilies =
      Set<String>.from(textElements.map((element) => element.fontFamily));

  return usedFontFamilies.toList();
}

List<TextElementModel> _extractTextElements(LayoutElementModel element) {
  if (element.child is TextElementModel) {
    return [element.child as TextElementModel];
  }

  if (element.child is MultiChildElementModel) {
    return (element.child as MultiChildElementModel)
        .children
        .values
        .expand((element) => _extractTextElements(element))
        .toList();
  }

  return [];
}
