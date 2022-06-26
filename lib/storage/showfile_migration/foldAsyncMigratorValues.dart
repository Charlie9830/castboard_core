import 'package:castboard_core/storage/ImportedShowData.dart';

Future<ImportedShowData> foldAsyncMigratorValues(
    ImportedShowData initialValue,
    Iterable<Future<ImportedShowData> Function(ImportedShowData data)>
        migrators) async {
  ImportedShowData value = initialValue;
  for (var migrator in migrators) {
    value = await migrator(value);
  }

  return value;
}
