import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';

Future<void> decompressShowfile(DecompressShowfileParameters params) async {
  return await compute<DecompressShowfileParameters, void>(
      _decompressShowfileWorker, params,
      debugLabel: 'File Decompression Isolate - decompressShowfile()');
}

Future<void> _decompressShowfileWorker(
    DecompressShowfileParameters params) async {
  final unzipper = ZipDecoder();
  final archive = unzipper.decodeBytes(params.bytes);

  extractArchiveToDisk(archive, params.targetDirPath);

  return;
}

class DecompressShowfileParameters {
  final String targetDirPath;
  final List<int> bytes;

  DecompressShowfileParameters({
    required this.targetDirPath,
    required this.bytes,
  });
}
