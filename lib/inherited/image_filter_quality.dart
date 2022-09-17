import 'package:flutter/material.dart';

class ImageFilterQuality extends InheritedWidget {
  final Widget child;

  final FilterQuality filterQuality;

  const ImageFilterQuality(
      {Key? key, required this.child, required this.filterQuality})
      : super(key: key, child: child);

  static ImageFilterQuality? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ImageFilterQuality>();
  }

  @override
  bool updateShouldNotify(ImageFilterQuality oldWidget) {
    return oldWidget.filterQuality != filterQuality;
  }
}
