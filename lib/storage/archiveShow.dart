import 'dart:io';

import 'package:castboard_core/storage/compressShowfile.dart';

/// Archives the show file provided by [source] to the file reference provided by [target]
Future<File> archiveShow(Directory source, File target) async {
  if (await source.exists() == false) {
    throw ArgumentError('Source directory does not exist', 'source');
  }

  await compressShowfile(CompressShowfileParameters(
    sourceDirPath: source.path,
    targetFilePath: target.path,
  ));

  return target;
}
