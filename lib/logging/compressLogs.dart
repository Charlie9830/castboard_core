import 'dart:io';

import 'package:archive/archive_io.dart';

void compressLogs(CompressLogsParameters params) {
  final zipper = ZipFileEncoder();
  zipper.create(params.targetFilePath);
  for (var path in params.logPaths) {
    zipper.addFile(File(path));
  }
  zipper.close();
}

class CompressLogsParameters {
  final String targetFilePath;
  final List<String> logPaths;

  CompressLogsParameters({
    required this.targetFilePath,
    required this.logPaths,
  });
}
