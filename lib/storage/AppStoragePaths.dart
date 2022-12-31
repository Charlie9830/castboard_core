import 'dart:io';

import 'package:path/path.dart' as p;

class AppStoragePaths {
  // Directories
  late Directory root;
  late Directory activeShow;
  late Directory backups;
  late Directory archive;
  late Directory showExport;
  late Directory temp;
  late Directory designerSettings;
  late Directory packageUpdate;

  // Files
  late File backupStatus;
  late File backupFile;
  late File lastDesignerExportSettingsFile;
  late File updateStatusFile;
  late File performerSettingsFile;

  AppStoragePaths(String rootPath) {
    // Directories
    root = Directory(rootPath);
    activeShow = Directory(p.join(root.path, 'active'));
    backups = Directory(p.join(root.path, 'backup'));
    archive = Directory(p.join(root.path, 'archive'));
    showExport = Directory(p.join(root.path, 'showExport'));
    temp = Directory(p.join(root.path, 'temp'));
    designerSettings = Directory(p.join(root.path, 'settings'));
    packageUpdate = Directory(p.join(root.path, 'update'));

    // Files
    backupStatus = File(p.join(backups.path, 'status'));
    backupFile = File(p.join(backups.path, 'backup.castboard'));
    lastDesignerExportSettingsFile =
        File(p.join(designerSettings.path, 'lastDesignerExport.json'));
    updateStatusFile = File(p.join(packageUpdate.path, 'status'));
    performerSettingsFile = File(p.join(root.path, 'performer_settings.json'));
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
      designerSettings.create(),
      packageUpdate.create(),
    ]);

    return;
  }
}
