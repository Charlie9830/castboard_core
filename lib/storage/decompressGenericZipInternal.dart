import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

Future<Directory> decompressGenericZipInternal(
    List<int> byteData, Directory targetDir) async {
  if (await targetDir.exists() == false) {
    await targetDir.create();
  }

  // Decode the Zip File
  final unzipper = ZipDecoder();
  final archive = unzipper.decodeBytes(byteData);
  for (final file in archive) {
    final entityName = file.name;
    if (file.isFile) {
      final data = file.content as List<int>;
      File(p.join(targetDir.path, entityName))
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      Directory(p.join(targetDir.path, entityName)).create(recursive: true);
    }
  }

  return targetDir;
}
