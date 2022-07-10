import 'dart:convert';
import 'dart:io';

import 'package:castboard_core/logging/LoggingManager.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/storage/ShowStoragePaths.dart';

Future<String> getShowfileName(Directory showfile) async {
  const unknownFileName = 'Show.castboard';
  final manifestFile = ShowStoragePaths(showfile.path).manifest;

  if (await manifestFile.exists() == false) {
    LoggingManager.instance.storage.warning(
        'Failed to retrieve showfile name from manifest. Using default.');
    return unknownFileName;
  }

  try {
    final rawData = json.decode(await manifestFile.readAsString());
    final manifest = ManifestModel.fromMap(rawData);

    return '${manifest.fileName}.castboard';
  } catch (e, stacktrace) {
    LoggingManager.instance.storage.warning(
        'Failed to retrieve showfile name from manifest. Using default.',
        e,
        stacktrace);
    return unknownFileName;
  }
}
