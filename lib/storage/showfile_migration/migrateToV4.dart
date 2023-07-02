import 'dart:io';

import 'package:castboard_core/storage/ImportedShowData.dart';

Future<ImportedShowData> migrateToV4(
  ImportedShowData source,
  Directory baseDir,
) async {
  // v4
  // -> Preserves png files when imported as Image Elements. No Migratation behaviour is required,
  //    however this breaks compatability with versions prior to file version v4.
  // -> Added Subtitles Feature. Uses Null value guarding so no specific migration required.
  return source.copyWith();
}
