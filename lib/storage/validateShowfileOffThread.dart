import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:flutter/foundation.dart';

Future<ShowfileValidationWorkerResult> validateShowfileOffThread({
  required List<int> byteData,
  required String manifestFileName,
  required int maxFileVersion,
  required String manifestValidationKey,
}) async {
  final result = await compute(
      validateShowFileWorker,
      ShowfileValidationWorkerArgs(
        byteData: byteData,
        manifestFileName: manifestFileName,
        manifestValidationKey: manifestValidationKey,
        maxFileVersion: maxFileVersion,
      ));

  return result;
}

ShowfileValidationWorkerResult validateShowFileWorker(
    ShowfileValidationWorkerArgs args) {
  final unzipper = ZipDecoder();
  late Archive archive;

  try {
    archive = unzipper.decodeBytes(args.byteData);
  } catch (e) {
    return ShowfileValidationWorkerResult(
        false,
        ShowfileValidationFailReason.incorrectEncoding,
        'File encoding does not match that of a Zip file. Exception Message: ${e}');
  }

  // Search for the Manifest.
  final manifestEntityHits = archive
      .where((ArchiveFile entity) => entity.name == args.manifestFileName);

  if (manifestEntityHits.isEmpty) {
    return ShowfileValidationWorkerResult(
        false,
        ShowfileValidationFailReason.manifestMissing,
        'No file matching the manifest found in archive.');
  }

  final manifestByteData = manifestEntityHits.first.content as List<int>?;

  if (manifestByteData == null || manifestByteData.length == 0) {
    return ShowfileValidationWorkerResult(
        false,
        ShowfileValidationFailReason.manifestMissing,
        'Manifest file is empty.');
  }

  final rawManifest = json.decode(utf8.decode(manifestByteData));

  if (rawManifest == null) {
    return ShowfileValidationWorkerResult(
        false,
        ShowfileValidationFailReason.manifestInvalid,
        'Json decoding of the manifest file returned null.');
  }

  late ManifestModel manifest;
  try {
    manifest = ManifestModel.fromMap(rawManifest);
  } catch (e) {
    return ShowfileValidationWorkerResult(
        false,
        ShowfileValidationFailReason.manifestInvalid,
        'Conversion from rawManifest map to ManifestModel threw an exception.');
  }

  if (manifest.validationKey != args.manifestValidationKey) {
    return ShowfileValidationWorkerResult(
        false,
        ShowfileValidationFailReason.manifestInvalid,
        'Manifest validation key is not correct. Expecting ${args.manifestValidationKey} got ${manifest.validationKey}');
  }

  if (manifest.fileVersion > args.maxFileVersion) {
    return ShowfileValidationWorkerResult(
        false,
        ShowfileValidationFailReason.incompatiableFileVersion,
        'Manifest file version is greater then Maximum allowed file version.');
  }

  return ShowfileValidationWorkerResult(
      true, ShowfileValidationFailReason.none, '',
      manifest: manifest);
}

enum ShowfileValidationFailReason {
  none,
  manifestMissing,
  manifestInvalid,
  incompatiableFileVersion,
  contentsEmpty,
  incorrectEncoding,
}

class ShowfileValidationWorkerResult {
  final bool isValid;
  final ShowfileValidationFailReason reason;
  final String message;
  final ManifestModel? manifest;

  ShowfileValidationWorkerResult(this.isValid, this.reason, this.message,
      {this.manifest});
}

class ShowfileValidationWorkerArgs {
  final List<int> byteData;
  final String manifestFileName;
  final int maxFileVersion;
  final String manifestValidationKey;

  ShowfileValidationWorkerArgs({
    required this.byteData,
    required this.manifestFileName,
    required this.maxFileVersion,
    required this.manifestValidationKey,
  });
}
