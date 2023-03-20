import 'dart:io';

import 'package:castboard_core/logging/LoggingManager.dart';
import 'package:castboard_core/path_provider_shims.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

Future<void> launchExternalDoc(String bundlePath) async {
  // Copy Reference Guide from Bundled Assets to temp directory.
  final tempDir = (await getTemporaryDirectoryShim()).path;
  final docsTargetDir = Directory(p.join(tempDir, 'castboard_docs'));

  try {
    await docsTargetDir.create();
  } catch (e, stacktrace) {
    LoggingManager.instance.general.warning(
        'Failed to create temp directory for Castboard Docs at ${docsTargetDir.path}',
        e,
        stacktrace);
    return;
  }

  final referenceGuideTargetFile =
      File(p.join(docsTargetDir.path, p.basename(bundlePath)));

  ByteData docBytes;
  try {
    docBytes = await rootBundle.load(bundlePath);
  } catch (e, stacktrace) {
    // Fail Gracefully.
    LoggingManager.instance.general
        .warning('Failed to retrieve Doc from asset bundle', e, stacktrace);
    return;
  }

  try {
    await referenceGuideTargetFile.writeAsBytes(docBytes.buffer.asUint8List());
  } catch (e, stacktrace) {
    // Fail Gracefully.
    LoggingManager.instance.general.warning(
        'Unable to write Doc bytes to Target file location $referenceGuideTargetFile',
        e,
        stacktrace);
    return;
  }

  await launchUrl(
      Uri.file(referenceGuideTargetFile.path, windows: Platform.isWindows));
}
