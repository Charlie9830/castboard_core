import 'dart:io';

import 'package:castboard_core/Environment.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

Future<Directory> getApplicationsDocumentDirectoryShim() async {
  if (Environment.isElinux) {
    return Directory(Environment.eLinuxHomePath);
  }

  return pathProvider.getApplicationDocumentsDirectory();
}

Future<Directory> getApplicationsSupportDirectoryShim() async {
  if (Environment.isElinux) {
    return Directory(Environment.eLinuxHomePath);
  }

  return pathProvider.getLibraryDirectory();
}

Future<Directory> getTemporaryDirectoryShim() async {
  if (Environment.isElinux) {
    return Directory(Environment.eLinuxTmpPath);
  }

  return pathProvider.getTemporaryDirectory();
}
