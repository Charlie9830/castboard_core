

import 'package:flutter/material.dart';

class SlideScroller extends StatefulWidget {
  final Widget? child;
  final bool enabled;
  const SlideScroller({
    Key? key,
    this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  _SlideScrollerState createState() => _SlideScrollerState();
}

class _SlideScrollerState extends State<SlideScroller> {
  bool _allowScrolling = true;

  @override
  Widget build(BuildContext context) {
    if (widget.enabled == false) {
      return widget.child!;
    }

    return SingleChildScrollView(
      primary: false,
      scrollDirection: Axis.vertical,
      physics: _allowScrolling
          ? const ClampingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: _allowScrolling
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: Listener(
            onPointerDown: (event) => setState(() => _allowScrolling = false),
            onPointerUp: (event) => setState(() => _allowScrolling = true),
            onPointerCancel: (event) => setState(() => _allowScrolling = true),
            child: widget.child),
      ),
    );
  }
}
