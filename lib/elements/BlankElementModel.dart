import 'package:castboard_core/classes/LayoutElementChild.dart';
import 'package:castboard_core/layout-canvas/element_ref.dart';

class BlankElementModel extends LayoutElementChild {
  @override
  Map<String, dynamic> toMap() {
    return {'elementType': 'blank'};
  }

  @override
  LayoutElementChild copy({ElementRef? parentId}) {
    return BlankElementModel();
  }
}
