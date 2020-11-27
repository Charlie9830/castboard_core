import 'package:castboard_core/inherited/RenderScaleProvider.dart';
import 'package:flutter/material.dart';

class NoHeadshotFallback extends StatelessWidget {
  final String roleTitle;
  const NoHeadshotFallback({Key key, this.roleTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final renderScale = RenderScale.of(context).scale;
    final textStyle = Theme.of(context).textTheme.bodyText1.copyWith(
          color: Colors.black,
          fontSize:
              Theme.of(context).textTheme.bodyText1.fontSize * renderScale,
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8 * renderScale)),
        border: Border.all(color: Colors.grey, width: 4 * renderScale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 100 * renderScale, color: Colors.black),
          Text(roleTitle ?? '', style: textStyle),
          Text('No Photo', style: textStyle),
        ],
      ),
    );
  }
}
