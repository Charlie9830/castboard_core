const String _kAttr = "cb-element";

String _wrapValue(String value) => '="$value" ';

class HTMLElementMapping {
  static final String imageElement = '$_kAttr${_wrapValue("image")}';
  static final String textElement = '$_kAttr${_wrapValue("textElement")}';
  static final String shapeElement = '$_kAttr${_wrapValue("shape")}';
  static final String groupElement = '$_kAttr${_wrapValue("group")}';
  static final String containerElement = '$_kAttr${_wrapValue("container")}';
  static final String backgroundElement = '$_kAttr${_wrapValue("background")}';
  static final String unimplementElement = '$_kAttr${_wrapValue("unimplemented")}';
  static final String textAligner = '$_kAttr${_wrapValue("text-aligner")}';
  static final String elementCanvas = '$_kAttr${_wrapValue("element-canvas")}';

}
