import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:castboard_core/layout-canvas/LayoutBlock.dart';
import 'package:flutter/material.dart';

class MultiChildCanvasItem extends StatelessWidget {
  final List<LayoutBlock> children;
  final EdgeInsets padding;
  const MultiChildCanvasItem(
      {Key? key, this.children = const [], this.padding = EdgeInsets.zero})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final renderScale = RenderScale.of(context)!.scale;

    return Padding(
      padding: padding,
      child: Stack(
        children: children
            .map((child) => Positioned(
                  left: child.xPos * renderScale! + padding.left,
                  top: child.yPos * renderScale + padding.top,
                  width: (child.width - (padding.horizontal * 2)) * renderScale,
                  height: (child.height - (padding.vertical * 2)) * renderScale,
                  child: Transform.rotate(
                    angle: child.rotation,
                    child: child,
                  ),
                ))
            .toList(),
      ),
    );
  }

  MultiChildCanvasItem copyWith({
    Key? key,
    List<LayoutBlock>? children,
    EdgeInsets? padding,
  }) {
    return MultiChildCanvasItem(
      key: key ?? this.key,
      children: children ?? this.children,
      padding: padding ?? this.padding,
    );
  }

  MultiChildCanvasItem copyWithScaledChildren(
      {double ratioX = 1, double ratioY = 1}) {
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
