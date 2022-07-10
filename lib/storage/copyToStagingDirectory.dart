import 'dart:io';
import 'package:path/path.dart' as p;

///
/// Copies the File refered by [sourceFile] to the Directory referenced by [targetDir].
///
Future<File> copyToStagingDir(File sourceFile, Directory targetDir) async {
  final targetFile = File(p.join(targetDir.path, p.basename(sourceFile.path)));
  await targetFile.create(recursive: true);
  final sourceFileBytes = await sourceFile.readAsBytes();
  return await targetFile.writeAsBytes(sourceFileBytes);
}
