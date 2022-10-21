import 'dart:convert';
import 'dart:io';

import 'package:castboard_core/logging/LoggingManager.dart';
import 'package:castboard_core/storage/ImportedShowData.dart';
import 'package:castboard_core/storage/showfile_migration/foldAsyncMigratorValues.dart';
import 'package:castboard_core/storage/showfile_migration/migrateToV2.dart';
import 'package:castboard_core/storage/showfile_migration/migrateToV3.dart';
import 'package:castboard_core/version/fileVersion.dart';

typedef ShowfileMigrator = Future<ImportedShowData> Function(
    ImportedShowData data, Directory baseDir);

Future<ImportedShowData> migrateShowfileData({
  required ImportedShowData currentShowData,
  required File manifestFile,
  required Directory baseDir,
}) async {
  if (currentShowData.manifest.fileVersion == kMaxAllowedFileVersion) {
    return currentShowData;
  } else {
    LoggingManager.instance.storage.info(
        'Showfile out of date. Initiating migration from Showfile Version ${currentShowData.manifest} to $kMaxAllowedFileVersion');
    // Chain a sequence of Migrator functions together. Each function will perform the necessary migrations to the underlying
    // data and files in the baseDir then return an updated copy of the Imported shwo Data.
    final List<ShowfileMigrator> migrators = [
      migrateToV2,
      migrateToV3,
    ];

    // Pick the approriate range of Migrator async functions.
    final migratorSubRange = migrators.getRange(
        currentShowData.manifest.fileVersion - 1, kMaxAllowedFileVersion - 1);

    // Asyncronously call each migrator function and reduce the values together.
    final data = await foldAsyncMigratorValues(
        currentShowData, baseDir, migratorSubRange);

    // Update the manifest version number.
    final updatedManifest =
        currentShowData.manifest.copyWith(fileVersion: kMaxAllowedFileVersion);
    await manifestFile.writeAsString(json.encode(updatedManifest.toMap()));

    LoggingManager.instance.storage.info(
        "Showfile migration complete. Showfile migrated to version $kMaxAllowedFileVersion");

    return data;
  }
}
