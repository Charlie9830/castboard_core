import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:flutter/material.dart';

class SlideViewport extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double renderScale;
  final BoxDecoration background;

  const SlideViewport({
    Key key,
    this.child,
    @required this.renderScale,
    this.width = 1920,
    this.height = 1080,
    this.background,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: RenderScale(
          scale: renderScale,
          child: Container(
            decoration: background,
            alignment: Alignment.center,
            width: width * renderScale,
            height: height * renderScale,
            child: child,
          ),
        ));
  }
}
