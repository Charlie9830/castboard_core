import 'dart:io';

import 'package:archive/archive_io.dart';

void compressFileWorker(CompressFileParameters params) {
  final zipper = ZipFileEncoder();
  zipper.create(params.targetFilePath);
  zipper.addDirectory(Directory(params.headshotsDirPath));
  zipper.addDirectory(Directory(params.backgroundsDirPath));
  zipper.addDirectory(Directory(params.fontsDirPath));
  zipper.addFile(File(params.manifestFilePath));
  zipper.addFile(File(params.showDataFilePath));
  zipper.addFile(File(params.slideDataFilePath));
  zipper.addFile(File(params.playbackStateFilePath));
  zipper.close();
}

class CompressFileParameters {
  final String targetFilePath;
  final String headshotsDirPath;
  final String backgroundsDirPath;
  final String fontsDirPath;
  final String manifestFilePath;
  final String showDataFilePath;
  final String slideDataFilePath;
  final String playbackStateFilePath;

  CompressFileParameters({
    required this.targetFilePath,
    required this.backgroundsDirPath,
    required this.fontsDirPath,
    required this.headshotsDirPath,
    required this.manifestFilePath,
    required this.playbackStateFilePath,
    required this.showDataFilePath,
    required this.slideDataFilePath,
  });
}
