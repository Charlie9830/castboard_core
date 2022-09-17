import 'dart:io';

import 'package:castboard_core/inherited/image_filter_quality.dart';
import 'package:flutter/material.dart';

class ImageElement extends StatelessWidget {
  final File? file;

  const ImageElement({Key? key, this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filterQuality =
        ImageFilterQuality.of(context)?.filterQuality ?? FilterQuality.medium;
    return Image.file(file!, fit: BoxFit.contain, filterQuality: filterQuality);
  }
}
