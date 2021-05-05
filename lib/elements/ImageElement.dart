import 'dart:io';

import 'package:flutter/material.dart';

class ImageElement extends StatelessWidget {
  final File file;

  const ImageElement({Key key, this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(alignment: Alignment.center, child: Image.file(file));
  }
}
