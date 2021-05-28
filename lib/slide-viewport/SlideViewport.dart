import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:castboard_core/slide-viewport/SlideScroller.dart';
import 'package:flutter/material.dart';

class SlideViewport extends StatelessWidget {
  final Widget child;
  final int slideWidth;
  final int slideHeight;
  final double slideRenderScale;
  final bool enableScrolling;
  final BoxDecoration background;

  const SlideViewport({
    Key key,
    this.child,
    @required this.slideRenderScale,
    this.slideWidth = 1920,
    this.slideHeight = 1080,
    this.enableScrolling = true,
    this.background,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: RenderScale(
        scale: slideRenderScale,
        child: SlideScroller(
          enabled: enableScrolling,
          child: Container(
            decoration: background,
            alignment: Alignment.center,
            width: (slideWidth * slideRenderScale).toDouble(),
            height: (slideHeight * slideRenderScale).toDouble(),
            child: child,
          ),
        ),
      ),
    );
  }
}
