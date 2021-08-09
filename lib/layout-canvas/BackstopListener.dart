import 'package:flutter/material.dart';

class BackstopListener extends StatelessWidget {
  final void Function(PointerDownEvent)? onPointerDown;
  final void Function(PointerUpEvent)? onPointerUp;
  final void Function(PointerMoveEvent)? onPointerMove;

  const BackstopListener({
    Key? key,
    this.onPointerDown,
    this.onPointerUp,
    this.onPointerMove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: onPointerDown,
      onPointerMove: onPointerMove,
      onPointerUp: onPointerUp,
      // Using a Container as the child forces the parent listener to expand and fill all available space.
      // I'm pretty sure that if you don't have a colour set on the container it wont 'expand'.
      child: Container(
        color: Colors.transparent,
      ),
    );
  }
}
