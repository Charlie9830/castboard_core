import 'package:castboard_core/models/PresetModel.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

enum ColorTagSelectorLabelPosition {
  top,
  bottom,
}

class ColorTagSelector extends StatelessWidget {
  final int selectedColorIndex;
  final void Function(int index)? onChange;
  final bool leftAligned;
  final ColorTagSelectorLabelPosition labelPosition;

  const ColorTagSelector({
    Key? key,
    this.selectedColorIndex = -1,
    this.leftAligned = false,
    this.onChange,
    this.labelPosition = ColorTagSelectorLabelPosition.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          leftAligned ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        if (labelPosition == ColorTagSelectorLabelPosition.top) ...[
          Text('Color Tag', style: Theme.of(context).textTheme.caption),
          const SizedBox(height: 4),
        ],
        Wrap(children: [
          // Clear Value
          InkWell(
              onTap: () => onChange?.call(-1),
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: const SizedBox(
                  width: 36, height: 36, child: Icon(Icons.clear_outlined))),
          // Rest of the Colors
          ...colorTags.mapIndexed((index, color) {
            return _ColorChit(
              selected: index == selectedColorIndex,
              color: color.toColor(),
              onTap: () => onChange?.call(index),
            );
          }).toList(),
        ]),
        if (labelPosition == ColorTagSelectorLabelPosition.bottom) ...[
          const SizedBox(height: 4),
          Text('Color Tag', style: Theme.of(context).textTheme.caption)
        ]
      ],
    );
  }
}

class _ColorChit extends StatelessWidget {
  final Color? color;
  final bool selected;
  final void Function() onTap;

  const _ColorChit(
      {Key? key, this.color, required this.selected, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            child: Container(
              margin: const EdgeInsets.all(8.0),
              width: 16,
              height: 16,
              foregroundDecoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 125),
            opacity: selected ? 1.0 : 0,
            child: SizedBox(
              height: 4,
              width: 24,
              child: Container(
                foregroundDecoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  color: Theme.of(context).indicatorColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
