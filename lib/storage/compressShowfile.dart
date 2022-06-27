import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';

Future<void> compressShowfile(CompressShowfileParameters params) async {
  await compute(_compressShowfileWorker, params,
      debugLabel: 'File Compression Isolate - compressShowfile()');
}

void _compressShowfileWorker(CompressShowfileParameters params) {
  final zipper = ZipFileEncoder();
  zipper.create(params.targetFilePath);
  zipper.addDirectory(Directory(params.headshotsDirPath));
  zipper.addDirectory(Directory(params.backgroundsDirPath));
  zipper.addDirectory(Directory(params.imagesDirPath));
  zipper.addDirectory(Directory(params.fontsDirPath));
  zipper.addDirectory(Directory(params.thumbsDirPath));
  zipper.addFile(File(params.manifestFilePath));
  zipper.addFile(File(params.showDataFilePath));
  zipper.addFile(File(params.slideDataFilePath));
  zipper.addFile(File(params.playbackStateFilePath));
  zipper.close();
}

class CompressShowfileParameters {
  final String targetFilePath;
  final String headshotsDirPath;
  final String backgroundsDirPath;
  final String fontsDirPath;
  final String imagesDirPath;
  final String manifestFilePath;
  final String showDataFilePath;
  final String slideDataFilePath;
  final String playbackStateFilePath;
  final String thumbsDirPath;

  CompressShowfileParameters({
    required this.targetFilePath,
    required this.backgroundsDirPath,
    required this.fontsDirPath,
    required this.imagesDirPath,
    required this.headshotsDirPath,
    required this.manifestFilePath,
    required this.playbackStateFilePath,
    required this.showDataFilePath,
    required this.slideDataFilePath,
    required this.thumbsDirPath,
  });
}
