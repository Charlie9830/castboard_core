import 'dart:io';

import 'package:castboard_core/logging/LoggingManager.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/storage/ShowStoragePaths.dart';
import 'package:castboard_core/storage/ShowfileValidationResult.dart';
import 'package:castboard_core/storage/decompressGenericZipInternal.dart';
import 'package:castboard_core/storage/validateShowfileOffThread.dart';

Future<ShowfileValidationResult> validateShowfileInternal(
    List<int> byteData, int maxFileVersion) async {
  final computedResult = await validateShowfileOffThread(
      byteData: byteData,
      manifestFileName: kShowfileManifestFileName,
      maxFileVersion: maxFileVersion,
      manifestValidationKey: kManifestModelValidationKeyValue);

  // File is Valid.
  if (computedResult.isValid) {
    return ShowfileValidationResult(true, true,
        manifest: computedResult.manifest);
  }

  // File is incompatiable version.
  if (computedResult.reason ==
      ShowfileValidationFailReason.incompatiableFileVersion) {
    LoggingManager.instance.storage
        .warning('Rejecting showfile, reason: ${computedResult.message}');
    return ShowfileValidationResult(false, false);
  }

  if (computedResult.reason == ShowfileValidationFailReason.incorrectEncoding) {
    LoggingManager.instance.storage.warning(
        'Unzipper Rejected showfile, reason: ${computedResult.message}');
    return ShowfileValidationResult(false, false);
  }

  // File is invalid. Could be a number of other reasons.
  LoggingManager.instance.storage
      .warning("Rejecting showfile, reason : ${computedResult.message}");
  return ShowfileValidationResult(false, true);
}

Future<Directory> decompressGenericZip(
    List<int> byteData, Directory targetDir) async {
  return decompressGenericZipInternal(byteData, targetDir);
}
