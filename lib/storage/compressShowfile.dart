
import 'package:archive/archive_io.dart';
import 'package:castboard_core/storage/ShowStoragePaths.dart';
import 'package:flutter/foundation.dart';

Future<void> compressShowfile(CompressShowfileParameters params) async {
  await compute(_compressShowfileWorker, params,
      debugLabel: 'File Compression Isolate - compressShowfile()');
}

void _compressShowfileWorker(CompressShowfileParameters params) {
  final paths = ShowStoragePaths(params.sourceDirPath);

  final zipper = ZipFileEncoder();
  zipper.create(params.targetFilePath);

  for (var dir in paths.subDirectories) {
    zipper.addDirectory(dir);
  }

  for (var file in paths.files) {
    zipper.addFile(file);
  }

  zipper.close();
}

class CompressShowfileParameters {
  final String targetFilePath;
  final String sourceDirPath;

  CompressShowfileParameters({
    required this.targetFilePath,
    required this.sourceDirPath,
  });
}
