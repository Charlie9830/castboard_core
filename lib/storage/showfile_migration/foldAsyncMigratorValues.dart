import 'dart:io';

import 'package:castboard_core/storage/ImportedShowData.dart';
import 'package:castboard_core/storage/showfile_migration/showfileMigration.dart';

Future<ImportedShowData> foldAsyncMigratorValues(ImportedShowData initialValue,
    Directory baseDir, Iterable<ShowfileMigrator> migrators) async {
  ImportedShowData value = initialValue;
  for (var migrator in migrators) {
    value = await migrator(value, baseDir);
  }

  return value;
}
