import 'dart:io';

import 'package:castboard_core/storage/ImportedShowData.dart';

Future<ImportedShowData> migrateToV3(
  ImportedShowData source,
  Directory baseDir,
) async {
  // V3 adds PresetModel.colorTag and removed PresetModel.isNestable. However the migratory behaviour is handled
  // implicitly.
  return source;
}
