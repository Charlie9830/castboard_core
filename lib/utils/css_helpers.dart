import 'package:flutter/cupertino.dart';

String convertToCssColor(Color color) {
  return 'rgba(${color.red}, ${color.green}, ${color.blue}, ${color.alpha})';
}

String convertToCssTextAlign(TextAlign alignment) {
  return alignment.name;
}

String convertToJustifyContent(MainAxisAlignment mainAxisAlignment) {
  switch (mainAxisAlignment) {
    case MainAxisAlignment.start:
      return 'flex-start';
    case MainAxisAlignment.end:
      return 'flex-end';
    case MainAxisAlignment.center:
      return 'center';
    case MainAxisAlignment.spaceBetween:
      return 'space-between';
    case MainAxisAlignment.spaceAround:
      return 'space-around';
    case MainAxisAlignment.spaceEvenly:
      return 'space-evenly';
  }
}

String convertToAlignItems(CrossAxisAlignment crossAxisAlignment) {
  switch (crossAxisAlignment) {
    case CrossAxisAlignment.start:
      return 'flex-start';
    case CrossAxisAlignment.end:
      return 'flex-end';
    case CrossAxisAlignment.center:
      return 'center';
    case CrossAxisAlignment.stretch:
      return 'stretch';
    case CrossAxisAlignment.baseline:
      return 'baseline';
  }
}

String convertRunAlignmentToJustifyContent(WrapAlignment runAlignment) {
  switch (runAlignment) {
    case WrapAlignment.start:
      return 'flex-start';
    case WrapAlignment.end:
      return 'flex-end';
    case WrapAlignment.center:
      return 'center';
    case WrapAlignment.spaceBetween:
      return 'space-between';
    case WrapAlignment.spaceAround:
      return 'space-around';
    case WrapAlignment.spaceEvenly:
      return 'space-evenly';
  }
}
