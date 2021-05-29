

import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:flutter/material.dart';

class NoTrackFallback extends StatelessWidget {
  const NoTrackFallback({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final renderScale = RenderScale.of(context)!.scale!;
    final textStyle = Theme.of(context).textTheme.bodyText1!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize:
              Theme.of(context).textTheme.bodyText1!.fontSize! * renderScale,
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8 * renderScale)),
        border: Border.all(color: Colors.grey, width: 4 * renderScale),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 100 * renderScale, color: Theme.of(context).colorScheme.onSurface),
          Text('No Track Assigned', style: textStyle),
        ],
      ),
    );
  }
}
