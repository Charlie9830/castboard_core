import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:flutter/material.dart';

enum HeadshotFallbackReason { noTrack, noPhoto, noActor }

class HeadshotFallback extends StatelessWidget {
  final HeadshotFallbackReason reason;

  const HeadshotFallback({
    Key? key,
    required this.reason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final renderScale = RenderScale.of(context)!.scale!;

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8 * renderScale)),
          border: Border.all(color: Colors.grey, width: 4 * renderScale),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: _IconDisplay(
          iconData: _getIcon(),
        ));
  }

  IconData _getIcon() {
    switch (reason) {
      case HeadshotFallbackReason.noTrack:
        return Icons.person;

      case HeadshotFallbackReason.noPhoto:
        return Icons.no_photography;

      case HeadshotFallbackReason.noActor:
        return Icons.person_off;
    }
  }
}

class _IconDisplay extends StatelessWidget {
  final IconData iconData;

  const _IconDisplay({
    Key? key,
    required this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final primaryConstraint = constraints.maxWidth < constraints.maxHeight
          ? constraints.maxWidth
          : constraints.maxHeight;

      final double iconSize =
          primaryConstraint != double.infinity && primaryConstraint >= 0
              ? primaryConstraint
              : 0;
      return Icon(iconData, size: iconSize);
    });
  }
}
