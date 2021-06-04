import 'package:castboard_core/classes/LayoutElementChild.dart';


class BlankElementModel extends LayoutElementChild {
  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': 'blank'
    };
  }

  @override
  LayoutElementChild copy() {
    return BlankElementModel();
  }
}
