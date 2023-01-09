import 'package:castboard_core/storage/Storage.dart';
import 'package:version/version.dart';
import 'package:path/path.dart' as p;

class LocalUpdatePackageModel {
  final String path;
  final Version version;

  LocalUpdatePackageModel({
    required this.path,
    required this.version,
  });

  factory LocalUpdatePackageModel.fromFilePath(String filePath) {
    return LocalUpdatePackageModel(
        path: filePath,
        version:
            _extractVersionFromFileName(p.basenameWithoutExtension(filePath)));
  }

  /// The checksumFilePath will match the file path of the Package but with a .json extension.
  String get manifestFilePath => p.join(
      Storage.instance.getPackageUpdateDirectory().path,
      '${p.basenameWithoutExtension(path)}.json');

  static Version _extractVersionFromFileName(String fileName) {
    // File name will be of the schema Castboard_Designer_{Platform}_{Major}_{Minor}_{Patch}.
    final regex = RegExp(r'(_\d+)');

    final matches = regex.allMatches(fileName).toList();

    if (matches.length != 3) {
      throw FormatException(
          'Invalid file naming scheme. File name does not match the prescribed versioning schema. $fileName');
    }

    final int major =
        int.parse(matches[0].group(1)!.replaceAll('_', '').trim());
    final int minor =
        int.parse(matches[1].group(1)!.replaceAll('_', '').trim());
    final int patch =
        int.parse(matches[2].group(1)!.replaceAll('_', '').trim());

    return Version(major, minor, patch);
  }
}
