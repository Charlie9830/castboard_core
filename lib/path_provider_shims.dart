import 'dart:io';

import 'package:castboard_core/Environment.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

Future<Directory> getApplicationsDocumentDirectoryShim() async {
  if (Environment.isElinux) {
    return Directory(Environment.eLinuxHomePath);
  }

  return path_provider.getApplicationDocumentsDirectory();
}

Future<Directory> getApplicationSupportDirectoryShim() async {
  if (Environment.isElinux) {
    return Directory(Environment.eLinuxHomePath);
  }

  return path_provider.getApplicationSupportDirectory();
}

Future<Directory> getLibraryDirectoryShim() async {
  if (Environment.isElinux) {
    return Directory(Environment.eLinuxHomePath);
  }

  return path_provider.getLibraryDirectory();
}

Future<Directory> getTemporaryDirectoryShim() async {
  if (Environment.isElinux) {
    return Directory(Environment.eLinuxTmpPath);
  }

  return path_provider.getTemporaryDirectory();
}
