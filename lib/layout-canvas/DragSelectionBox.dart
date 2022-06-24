

import 'package:flutter/material.dart';

class DragSelectionBox extends StatelessWidget {
  const DragSelectionBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withAlpha(64),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
          )),
    );
  }
}
