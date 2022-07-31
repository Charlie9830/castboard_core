import 'dart:io';

import 'package:castboard_core/storage/ShowStoragePaths.dart';
import 'package:path/path.dart' as p;

class AppStoragePaths {
  // Directories
  late Directory root;
  late Directory activeShow;
  late Directory backups;
  late Directory archive;
  late Directory showExport;
  late Directory temp;

  // Files
  late File backupStatus;
  late File backupFile;

  AppStoragePaths(String rootPath) {
    // Directories
    root = Directory(rootPath);
    activeShow = Directory(p.join(root.path, 'active'));
    backups = Directory(p.join(root.path, 'backup'));
    archive = Directory(p.join(root.path, 'archive'));
    showExport = Directory(p.join(root.path, 'showExport'));
    temp = Directory(p.join(root.path, 'temp'));

    // Files
    backupStatus = File(p.join(backups.path, 'status'));
    backupFile = File(p.join(backups.path, 'backup.castboard'));
  }

  ///
  /// Creates all directories, including the [root] directory.
  ///
  Future<void> createDirectories() async {
    await Future.wait([
      root.create(),
      activeShow.create(),
      backups.create(),
      archive.create(),
      showExport.create(),
      temp.create(),
    ]);

    return;
  }
}
