import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:castboard_core/storage/getParentDirectoryName.dart';
import 'package:flutter/foundation.dart';

import 'package:path/path.dart' as p;

Future<String> decompressShowfile(DecompressShowfileParameters params) async {
  return await compute<DecompressShowfileParameters, String>(
      _decompressShowfileWorker, params,
      debugLabel: 'File Decompression Isolate - decompressShowfile()');
}

Future<String> _decompressShowfileWorker(
    DecompressShowfileParameters params) async {
  final targetDirPath = params.targetDirPath;
  final unzipper = ZipDecoder();
  final archive = unzipper.decodeBytes(params.bytes);

  // For files that are stored at the top level of showfile, which will be targeted to the targetDir. We can use a file writer delegate for DRY purposes.
  topLevelFileWriterDelegate(String name, List<int> byteData) =>
      File(p.join(params.targetDirPath, p.basename(name)))
          .writeAsBytes(byteData);

  final fileWriteRequests = <Future<File>>[];

  String byteDataSkippedFiles = '';

  for (var entity in archive) {
    final name = entity.name;
    final parentDirectoryName = getParentDirectoryName(name);

    if (entity.isFile) {
      final byteData = entity.content as List<int>?;

      if (byteData == null) {
        // If byteData is null. Add the name to a string that we will log later and continue on.
        byteDataSkippedFiles = '"${entity.name}", ';
        continue;
      }

      // Headshots
      if (parentDirectoryName == params.headshotsDirName) {
        fileWriteRequests.add(File(p.join(
                targetDirPath, params.headshotsDirName, p.basename(name)))
            .writeAsBytes(byteData));
      }

      // Backgrounds
      if (parentDirectoryName == params.backgroundsDirName) {
        fileWriteRequests.add(File(p.join(
                targetDirPath, params.backgroundsDirName, p.basename(name)))
            .writeAsBytes(byteData));
      }

      // Fonts
      if (parentDirectoryName == params.fontsDirName) {
        fileWriteRequests.add(
            File(p.join(targetDirPath, params.fontsDirName, p.basename(name)))
                .writeAsBytes(byteData));
      }

      // Images
      if (parentDirectoryName == params.imagesDirName) {
        fileWriteRequests.add(
            File(p.join(targetDirPath, params.imagesDirName, p.basename(name)))
                .writeAsBytes(byteData));
      }

      // Thumbs
      if (parentDirectoryName == params.thumbsDirName) {
        fileWriteRequests.add(
            File(p.join(targetDirPath, params.thumbsDirName, p.basename(name)))
                .writeAsBytes(byteData));
      }

      // Manifest
      if (name == params.manifestFileName) {
        fileWriteRequests.add(topLevelFileWriterDelegate(name, byteData));
      }

      // Show Data (Actors, Tracks, Presets)
      if (name == params.showDataFileName) {
        fileWriteRequests.add(topLevelFileWriterDelegate(name, byteData));
      }

      // Slide Data (Slides, SlideSize, SlideOrientation)
      if (name == params.slideDataFileName) {
        fileWriteRequests.add(topLevelFileWriterDelegate(name, byteData));
      }

      // Playback State (Currently displayed Cast Change etc)
      if (name == params.playbackStateFileName) {
        fileWriteRequests.add(topLevelFileWriterDelegate(name, byteData));
      }
    }
  }

  await Future.wait(fileWriteRequests);

  return byteDataSkippedFiles;
}

class DecompressShowfileParameters {
  final String targetDirPath;
  final List<int> bytes;

  final String headshotsDirName;
  final String backgroundsDirName;
  final String playbackStateFileName;
  final String slideDataFileName;
  final String showDataFileName;
  final String manifestFileName;
  final String thumbsDirName;
  final String imagesDirName;
  final String fontsDirName;

  DecompressShowfileParameters({
    required this.targetDirPath,
    required this.bytes,
    required this.backgroundsDirName,
    required this.fontsDirName,
    required this.headshotsDirName,
    required this.imagesDirName,
    required this.manifestFileName,
    required this.playbackStateFileName,
    required this.showDataFileName,
    required this.slideDataFileName,
    required this.thumbsDirName,
  });
}
