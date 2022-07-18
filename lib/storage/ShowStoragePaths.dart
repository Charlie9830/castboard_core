import 'dart:io';

import 'package:path/path.dart' as p;

const kShowfileManifestFileName = 'manifest.json';

class ShowStoragePaths {
  // Directories
  late Directory root;
  late Directory headshots;
  late Directory backgrounds;
  late Directory fonts;
  late Directory images;
  late Directory thumbs;

  List<Directory> get subDirectories {
    return [
      headshots,
      backgrounds,
      fonts,
      images,
      thumbs,
    ];
  }

  // Files
  late File manifest;
  late File slideData;
  late File showData;
  late File playbackState;

  List<File> get files {
    return [
      manifest,
      slideData,
      showData,
      playbackState,
    ];
  }

  ShowStoragePaths(String rootPath) {
    // Directories
    root = Directory(rootPath);
    headshots = Directory(p.join(rootPath, 'headshots'));
    backgrounds = Directory(p.join(rootPath, 'backgrounds'));
    fonts = Directory(p.join(rootPath, 'fonts'));
    images = Directory(p.join(rootPath, 'images'));
    thumbs = Directory(p.join(rootPath, 'thumbs'));

    // Files.
    manifest = File(p.join(rootPath, kShowfileManifestFileName));
    slideData = File(p.join(rootPath, 'slidedata.json'));
    showData = File(p.join(rootPath, 'showdata.json'));
    playbackState = File(p.join(rootPath, 'playback_state.json'));
  }

  ///
  /// Creates all directories, including the [root] directory.
  ///
  Future<void> createDirectories() async {
    await Future.wait([
      root.create(),
      headshots.create(),
      backgrounds.create(),
      fonts.create(),
      images.create(),
      thumbs.create(),
    ]);

    return;
  }

  ///
  /// Clears the contents of the root directory referenced by [root].
  ///
  Future<void> clearContents() async {
    if (await root.exists() == false) {
      return;
    }

    await for (var entity in root.list()) {
      await entity.delete(recursive: true);
    }
  }

  ///
  /// Resets the contents of the [root] directory to a clean state. Calls [clearContents] then [createDirectories]
  ///
  Future<void> reset() async {
    await clearContents();
    await createDirectories();
  }

  ///
  /// Directory base name getters.
  ///
  String get rootDirName {
    return p.basename(root.path);
  }

  String get headshotsDirName {
    return p.basename(headshots.path);
  }

  String get backgroundsDirName {
    return p.basename(backgrounds.path);
  }

  String get imagesDirName {
    return p.basename(images.path);
  }

  String get fontsDirName {
    return p.basename(fonts.path);
  }

  String get thumbsDirName {
    return p.basename(thumbs.path);
  }

  ///
  /// File base name getters
  ///
  String get manifestFileName {
    return p.basename(manifest.path);
  }

  String get showDataFileName {
    return p.basename(showData.path);
  }

  String get slideDataFileName {
    return p.basename(slideData.path);
  }

  String get playbackStateFileName {
    return p.basename(playbackState.path);
  }
}
