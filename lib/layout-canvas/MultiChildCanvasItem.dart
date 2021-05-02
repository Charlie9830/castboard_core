import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:castboard_core/layout-canvas/LayoutBlock.dart';
import 'package:flutter/material.dart';

class MultiChildCanvasItem extends StatelessWidget {
  final List<LayoutBlock> children;
  const MultiChildCanvasItem({Key key, this.children = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final renderScale = RenderScale.of(context).scale;
    return Stack(
      children: children
              .map((child) => Positioned(
                    left: child.xPos * renderScale,
                    top: child.yPos * renderScale,
                    width: child.width * renderScale,
                    height: child.height * renderScale,
                    child: Transform.rotate(
                      angle: child.rotation,
                      child: child,
                    ),
                  ))
              .toList() ??
          const [],
    );
  }

  MultiChildCanvasItem copyWith({
    Key key,
    List<LayoutBlock> children,
  }) {
    return MultiChildCanvasItem(
      key: key ?? this.key,
      children: children ?? this.children,
    );
  }

  MultiChildCanvasItem copyWithScaledChildren({double ratioX, double ratioY}) {
    return copyWith(
        children: children.map(
      (child) {
        return child.copyWith(
          xPos: child.xPos * ratioX,
          width: child.width * ratioX,
          yPos: child.yPos * ratioY,
          height: child.height * ratioY,
        );
      },
    ).toList());
  }
}
