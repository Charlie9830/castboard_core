import 'package:castboard_core/models/ActorIndex.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/TrackIndex.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/storage/ImportedShowData.dart';
import 'package:castboard_core/storage/showfile_migration/foldAsyncMigratorValues.dart';
import 'package:castboard_core/storage/showfile_migration/migrateToV2.dart';
import 'package:castboard_core/version/fileVersion.dart';

Future<ImportedShowData> applyMigrations({
  required ImportedShowData source,
  required ManifestModel manifest,
}) async {
  if (manifest.fileVersion == kMaxAllowedFileVersion) {
    return source;
  } else {
    // Chain a sequence of Migrator functions together. Each function will perform the neccassary migrations to the underlying
    // data and return an updated copy.
    final List<Future<ImportedShowData> Function(ImportedShowData data)>
        migrators = [
      migrateToV2,
    ];

    // Pick the approriate range of Migrator async functions.
    final migratorSubRange = migrators.getRange(
        manifest.fileVersion - 1, kMaxAllowedFileVersion - 1);

    // Asyncronously call each migrator function and reduce the values together.
    return await foldAsyncMigratorValues(source, migratorSubRange);
  }
}
