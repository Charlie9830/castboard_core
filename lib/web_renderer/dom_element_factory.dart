import 'package:html/dom.dart' as dom;

abstract class DomElementFactory {
  static dom.Element buildDiv({String style = '', String cbElementTag = ''}) {
    final element = dom.Element.tag('div')..attributes.addAll({'style': style});

    if (cbElementTag.isNotEmpty) {
      element.attributes.addAll({'cb-element': cbElementTag});
    }

    return element;
  }
}
