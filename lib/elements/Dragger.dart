import 'package:castboard_core/layout-canvas/element_ref.dart';
import 'package:flutter/material.dart';

enum HoverSide { start, end }

typedef OnHover = void Function(
    HoverSide side, DraggerDetails? candidateDetails);
typedef OnDragEnd = void Function(DraggerDetails? candidateDetails);
typedef FeedbackBuilder = Widget Function(BuildContext context);

class Dragger extends StatelessWidget {
  final Widget child;
  final Axis axis;
  final bool targetOnly;
  final DraggerDetails? dragData;
  final OnHover? onHover;
  final dynamic onDragStart;
  final OnDragEnd? onDragEnd;
  final FeedbackBuilder? feedbackBuilder;
  final bool deferHitTestingToChild;
  final ElementRef id;

  const Dragger({
    Key? key,
    required this.child,
    required this.id,
    this.feedbackBuilder,
    this.axis = Axis.horizontal,
    this.targetOnly = false,
    this.dragData,
    this.onHover,
    this.onDragStart,
    this.onDragEnd,
    this.deferHitTestingToChild = false,
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
            key: ValueKey(id),
            delay: const Duration(milliseconds: 200),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: feedbackBuilder != null
                ? Builder(builder: feedbackBuilder as FeedbackBuilder)
                : const SizedBox.shrink(),
            childWhenDragging: const SizedBox.shrink(),
            data: dragData,
            onDragStarted:
                deferHitTestingToChild ? null : () => onDragStart?.call(),
            onDragEnd: deferHitTestingToChild
                ? null
                : (_) => onDragEnd?.call(dragData),
            maxSimultaneousDrags: deferHitTestingToChild ? 0 : null,
            child: child,
          )
      ],
    );
  }

  Widget _wrapAxisContainer(
      {required Axis axis, required List<Widget> children}) {
    switch (axis) {
      case Axis.horizontal:
        return Row(
          children: children,
        );
      case Axis.vertical:
        return Column(
          children: children,
        );
      default:
        throw Exception(
            "Unknown axis provided to _wrapAxisContainer. Value provided is $axis");
    }
  }
}

class DraggerDetails {
  final ElementRef? id;
  final int index;

  DraggerDetails(this.id, this.index);
}
