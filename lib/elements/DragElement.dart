import 'package:flutter/material.dart';

typedef void OnDrop(String droppedId, int oldIndex);

class DragElement extends StatelessWidget {
  final Widget child;
  final String id;
  final int dragIndex;
  final OnDrop onDrop;
  final dynamic onHoverEnter;
  final dynamic onHoverLeave;

  const DragElement({
    Key key,
    @required this.id,
    @required this.child,
    @required this.dragIndex,
    this.onDrop,
    this.onHoverEnter,
    this.onHoverLeave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      feedback: Opacity(
        child: child,
        opacity: 0.5,
      ),
      childWhenDragging: Container(
        color: Theme.of(context).highlightColor,
      ),
      child: DragTarget<String>(
          onWillAccept: (data) {
            onHoverEnter?.call(data, dragIndex);
            return data != id;
          },
          onLeave: (data) => onHoverLeave?.call(data, dragIndex),
          onAccept: (data) => onDrop?.call(id, dragIndex),
          builder: (context, listA, listB) => child),
    );
  }
}
