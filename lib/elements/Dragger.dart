import 'package:flutter/material.dart';

enum HoverSide { start, end }

typedef void OnHover(HoverSide side, DraggerDetails? candidateDetails);
typedef void OnDragEnd(DraggerDetails? candidateDetails);
typedef Widget FeedbackBuilder(BuildContext context);

class Dragger extends StatelessWidget {
  final Widget? child;
  final Axis? axis;
  final bool targetOnly;
  final DraggerDetails? dragData;
  final OnHover? onHover;
  final dynamic onDragStart;
  final OnDragEnd? onDragEnd;
  final FeedbackBuilder? feedbackBuilder;

  const Dragger({
    Key? key,
    required this.child,
    this.feedbackBuilder,
    this.axis = Axis.horizontal,
    this.targetOnly = false,
    this.dragData,
    this.onHover,
    this.onDragStart,
    this.onDragEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        _wrapAxisContainer(
          axis: axis,
          children: [
            // Start (Left or Top)
            Expanded(
              child: DragTarget<DraggerDetails>(
                onWillAccept: (details) {
                  onHover?.call(HoverSide.start, details);
                  return true;
                },
                builder: (context, listA, listB) {
                  return Container(
                    alignment: Alignment.center,
                  );
                },
              ),
            ),
            // End (Right or Bottom)
            Expanded(
              child: DragTarget<DraggerDetails>(
                onWillAccept: (details) {
                  onHover?.call(HoverSide.end, details);
                  return true;
                },
                builder: (context, listA, listB) {
                  return Container(
                    alignment: Alignment.center,
                  );
                },
              ),
            ),
          ],
        ),

        // Draggable.
        if (targetOnly == false)
          LongPressDraggable<DraggerDetails>(
            delay: Duration(milliseconds: 25),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: feedbackBuilder != null
                ? Builder(builder: feedbackBuilder as FeedbackBuilder)
                : SizedBox.shrink(),
            child: child!,
            childWhenDragging: SizedBox.shrink(),
            data: dragData,
            onDragStarted: () => onDragStart?.call(),
            onDragEnd: (_) => onDragEnd?.call(dragData),
          )
      ],
    );
  }

  Widget _wrapAxisContainer({Axis? axis, List<Widget>? children}) {
    switch (axis) {
      case Axis.horizontal:
        return Row(
          children: children!,
        );
      case Axis.vertical:
        return Column(
          children: children!,
        );
      default:
        throw Exception(
            "Unknown axis provided to _wrapAxisContainer. Value provided is $axis");
    }
  }
}

class DraggerDetails {
  final String? id;
  final int index;

  DraggerDetails(this.id, this.index);
}
