

import 'dart:io';

import 'package:flutter/material.dart';

class ImageElement extends StatelessWidget {
  final File? file;

  const ImageElement({Key? key, this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.file(file!, fit: BoxFit.contain, filterQuality: FilterQuality.medium,);
  }
}
