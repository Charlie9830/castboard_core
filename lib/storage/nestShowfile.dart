import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';

Future<void> nestShowfile(NestShowfileParameters params) async {
  await compute(_nestShowfileWorker, params,
      debugLabel: 'File Compression Isolate - nestShowfile()');
}

void _nestShowfileWorker(NestShowfileParameters params) {
  final zipper = ZipFileEncoder();
  zipper.create(params.outputFilePath);
  zipper.addFile(File(params.inputFilePath));
  zipper.close();
}

class NestShowfileParameters {
  final String inputFilePath;
  final String outputFilePath;

  NestShowfileParameters({
    required this.inputFilePath,
    required this.outputFilePath,
  });
}
