import 'dart:io';

import 'package:castboard_core/storage/ImportedShowData.dart';

Future<ImportedShowData> migrateToV4(
  ImportedShowData source,
  Directory baseDir,
) async {
  // V4 Preserves png files when imported as Image Elements. No Migratation behaviour is required, however this breaks compatability with versions prior to file version v4.
  return source.copyWith();
}
