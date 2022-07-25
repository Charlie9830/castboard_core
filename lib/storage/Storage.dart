import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:castboard_core/classes/FontRef.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/logging/LoggingManager.dart';
import 'package:castboard_core/models/ActorIndex.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/FontModel.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/RemoteCastChangeData.dart';
import 'package:castboard_core/models/TrackIndex.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/path_provider_shims.dart';
import 'package:castboard_core/storage/AppStoragePaths.dart';
import 'package:castboard_core/storage/ShowStoragePaths.dart';
import 'package:castboard_core/storage/FileWriteResult.dart';
import 'package:castboard_core/storage/ImportedShowData.dart';
import 'package:castboard_core/models/ShowDataModel.dart';
import 'package:castboard_core/storage/ShowfileValidationResult.dart';
import 'package:castboard_core/storage/SlideDataModel.dart';
import 'package:castboard_core/storage/archiveShow.dart';
import 'package:castboard_core/storage/compressShowfile.dart';
import 'package:castboard_core/storage/copyToStagingDirectory.dart';
import 'package:castboard_core/storage/createThumbnail.dart';
import 'package:castboard_core/storage/decompressGenericZipInternal.dart';
import 'package:castboard_core/storage/decompressShowfile.dart';
import 'package:castboard_core/storage/extractImageRefs.dart';
import 'package:castboard_core/storage/getShowfileName.dart';
import 'package:castboard_core/storage/nestShowfile.dart';
import 'package:castboard_core/storage/showfile_migration/showfileMigration.dart';
import 'package:castboard_core/storage/validateShowfileInternal.dart';
import 'package:castboard_core/version/fileVersion.dart';

import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/storage/StorageException.dart';

import 'package:path/path.dart' as p;

// Storage root names
const editorStorageRootDirName = "com.charliehall.castboard-designer";
const performerStorageRootDirName = "com.charliehall.castboard-performer";

// Staging Directory Base Name.
const _stagingDirName = 'castboard_file_staging';

enum StorageMode {
  editor,
  performer,
}

class Storage {
  static Storage? _instance;
  static bool _initialized = false;

  final AppStoragePaths _appStoragePaths;
  final ShowStoragePaths _activeShowPaths;

  bool isWriting = false;
  bool isReading = false;

  static bool get initialized => _initialized;

  static Storage get instance {
    if (_initialized == false || _instance == null) {
      throw StorageException(
          'Storage() has not been initialized Yet. Ensure you are calling Storage.initalize() prior to making any other calls');
    }

    return _instance!;
  }

  Storage(
      {required AppStoragePaths appStoragePaths,
      required ShowStoragePaths activeShowPaths})
      : _appStoragePaths = appStoragePaths,
        _activeShowPaths = activeShowPaths;

  static Future<void> initialize(StorageMode mode) async {
    if (_initialized) {
      throw StorageException(
          'Storage is already initalized. Ensure you are only calling Storage.initialize() once');
    }

    // Create a the root storage directory. Use the correct App name based on if we are running inside the editor or the
    // performer.
    late final Directory rootDir;
    try {
      rootDir = mode == StorageMode.editor
          ? await Directory(p.join((await getTemporaryDirectoryShim()).path,
                  editorStorageRootDirName))
              .create()
          : await Directory(p.join(
                  (await getApplicationsDocumentDirectoryShim()).path,
                  performerStorageRootDirName))
              .create();
    } catch (e, stacktrace) {
      LoggingManager.instance.storage.severe(
          'An error occurred whilst creating the app storage root directory.',
          e,
          stacktrace);

      throw StorageException('The Storage directory could not be created');
    }

    LoggingManager.instance.storage
        .info("Storage root directory created as $mode at ${rootDir.path}");

    // Initialize the app Directory structure. Ensure all relevant Directories exist.
    late final AppStoragePaths appStoragePaths;
    try {
      // Create the first level of directories, these are the parents of all following directories.
      appStoragePaths = AppStoragePaths(rootDir.path);
      await appStoragePaths.createDirectories();
    } catch (e, stacktrace) {
      LoggingManager.instance.storage.severe(
          'An error occured whilst creating the Active Show Directory or the Archive Directory',
          e,
          stacktrace);
      return;
    }

    // Create the remaining sub directories.
    final activeShowPaths = ShowStoragePaths(appStoragePaths.activeShow.path);
    try {
      await activeShowPaths.createDirectories();
    } catch (e, stacktrace) {
      LoggingManager.instance.storage.severe(
          'An error occured whilst creating one of the storage sub directories. ',
          e,
          stacktrace);
      return;
    }

    _instance = Storage(
      appStoragePaths: appStoragePaths,
      activeShowPaths: activeShowPaths,
    );
    _initialized = true;

    LoggingManager.instance.storage
        .info("Storage initialization completed succesfully");
  }

  File getBackupFile() {
    return _appStoragePaths.backupFile;
  }

  File getBackupStatusFile() {
    return _appStoragePaths.backupStatus;
  }

  Future<ManifestModel?> getBackupFileManifest() async {
    final backupFile = getBackupFile();

    if (await backupFile.exists() == false) {
      return null;
    }

    final byteData = await backupFile.readAsBytes();
    final validateShowfileResult =
        await validateShowfileInternal(byteData, kMaxAllowedFileVersion);

    if (validateShowfileResult.isValid == false) return null;

    return validateShowfileResult.manifest;
  }

  Future<File> addFont(String uid, String path) async {
    LoggingManager.instance.server.info("Adding font from $path");
    final Directory fonts = _activeShowPaths.fonts;

    final font = File(path);
    if (await font.exists()) {
      final ext = p.extension(path);
      final targetFile = await font.copy(p.join(fonts.path, '$uid$ext'));

      return targetFile;
    } else {
      throw StorageException('Source Font file does not exist');
    }
  }

  Future<File> addHeadshot(String uid, String path) async {
    LoggingManager.instance.storage.info("Adding headshot from $path");
    final Directory headshots = _activeShowPaths.headshots;

    final photo = File(path);
    if (await photo.exists()) {
      final ext = p.extension(path);
      final targetFile = await photo.copy(p.join(headshots.path, '$uid$ext'));

      // Create and store a thumbnail.
      await createThumbnail(
          sourceFile: photo,
          targetFilePath: p.join(_activeShowPaths.thumbs.path, uid));

      return targetFile;
    } else {
      throw StorageException('Source Photo File does not exist');
    }
  }

  Future<void> addThumbnails(List<String> uids, List<File> sourceFiles,
      {Directory? baseDir}) async {
    final thumbsDirPath = baseDir == null
        ? _activeShowPaths.thumbs.path
        : ShowStoragePaths(baseDir.path).thumbs.path;

    await createThumbnails(
        sourceFiles: sourceFiles,
        targetFilePaths:
            uids.map((uid) => p.join(thumbsDirPath, uid)).toList());

    return;
  }

  Future<void> updateHeadshot(
      ImageRef current, String newId, File newHeadshot) async {
    LoggingManager.instance.storage
        .info("Updating headshot ${current.uid} to $newId");
    await addHeadshot(newId, newHeadshot.path);
    await deleteHeadshot(current);

    return;
  }

  Future<void> deleteHeadshot(ImageRef ref) async {
    LoggingManager.instance.storage.info("Deleting Headshot ${ref.uid}");
    final Directory headshots = _activeShowPaths.headshots;
    final File headshotFile = File(p.join(headshots.path, ref.basename));
    final File thumbFile =
        File(p.join(_activeShowPaths.thumbs.path, ref.uid) + kThumbnailFileExt);

    Future<void> deleteDelegate(File target) async {
      if (await target.exists()) target.delete();

      return;
    }

    await Future.wait([
      deleteDelegate(headshotFile),
      deleteDelegate(thumbFile),
    ]);

    return;
  }

  Future<void> deleteFont(FontRef ref) async {
    LoggingManager.instance.storage.info("Deleting Font ${ref.uid}");
    final Directory fonts = _activeShowPaths.fonts;
    final File file = File(p.join(fonts.path, ref.basename));

    if (await file.exists()) {
      await file.delete();
      return;
    }

    return;
  }

  Future<File> addBackground(String uid, String path) async {
    LoggingManager.instance.storage.info("Adding background from $path");
    final image = File(path);

    if (await image.exists()) {
      final ext = p.extension(path);
      final targetFile = await image
          .copy(p.join(_activeShowPaths.backgrounds.path, '$uid$ext'));

      return targetFile;
    } else {
      throw StorageException('Source Background File does not exist');
    }
  }

  Future<File> addImage(String uid, String path) async {
    LoggingManager.instance.storage.info("Adding Image from $path");
    final image = File(path);

    if (await image.exists()) {
      final ext = p.extension(path);
      final targetFile =
          await image.copy(p.join(_activeShowPaths.images.path, '$uid$ext'));

      return targetFile;
    } else {
      throw StorageException('Source Image File does not exist');
    }
  }

  Future<void> updateBackground(
      ImageRef current, String newId, File newBackground) async {
    LoggingManager.instance.storage
        .info("Updating background from ${current.uid} to $newId");
    await addBackground(newId, newBackground.path);
    await deleteBackground(current);

    return;
  }

  Future<void> deleteBackground(ImageRef ref) async {
    LoggingManager.instance.storage.info("Deleting background ${ref.uid}");
    final Directory backgrounds = _activeShowPaths.backgrounds;
    final File file = File(p.join(backgrounds.path, ref.basename));

    if (await file.exists()) {
      await file.delete();
      return;
    }

    return;
  }

  Future<void> deleteImage(ImageRef ref) async {
    LoggingManager.instance.storage.info("Deleting Image ${ref.uid}");
    final File file = File(p.join(_activeShowPaths.images.path, ref.basename));

    if (await file.exists()) {
      await file.delete();
      return;
    }

    return;
  }

  File? getHeadshotFile(
    ImageRef ref, {
    Directory? baseDir,
  }) {
    if (ref.uid == null || ref.uid!.isEmpty) {
      return null;
    }

    final dirPath = baseDir == null
        ? _activeShowPaths.headshots.path
        : ShowStoragePaths(baseDir.path).headshots.path;

    return File(p.join(dirPath, ref.basename));
  }

  File? getThumbnailFile(ImageRef ref) {
    if (ref.uid == null || ref.uid!.isEmpty) {
      return null;
    }

    return File(
        p.join(_activeShowPaths.thumbs.path, ref.uid) + kThumbnailFileExt);
  }

  File? getBackgroundFile(ImageRef ref) {
    if (ref.uid == null || ref.uid!.isEmpty) {
      return null;
    }

    return File(p.join(_activeShowPaths.backgrounds.path, ref.basename));
  }

  File? getImageFile(ImageRef ref) {
    if (ref.uid == null || ref.uid!.isEmpty) {
      return null;
    }

    return File(p.join(_activeShowPaths.images.path, ref.basename));
  }

  File? getFontFile(FontRef ref) {
    return File(
      p.join(_activeShowPaths.fonts.path, ref.basename),
    );
  }

  /// Checks that a showfile Manifest file exists and it is not empty is the Performer storage directory (Not the Archive directory)
  Future<bool> isPerformerStoragePopulated() async {
    final manifestFile = _activeShowPaths.manifest;

    return await manifestFile.exists() &&
        (await manifestFile.readAsString()).isNotEmpty;

    // TODO: This should also validate the manifest.
  }

  Future<bool> updatePerformerShowData({
    required ShowDataModel showData,
    required PlaybackStateData playbackState,
  }) async {
    LoggingManager.instance.storage.info("Updating Performer show data");

    final showDataFile = _activeShowPaths.showData;
    final playbackStateFile = _activeShowPaths.playbackState;

    final writeOperations = [
      showDataFile.writeAsString(json.encode(showData.toMap())),
      playbackStateFile.writeAsString(json.encode(playbackState.toMap()))
    ];

    try {
      await Future.wait(writeOperations);
      return true;
    } catch (e) {
      LoggingManager.instance.storage.severe(
          "Something went wrong whilst during a call to updatePerformerShowData, \n ${e.toString()}");
      return false;
    }
  }

  /// Reads in the showfile from provided [path] otherwise the Active show Directory.
  /// If [allowMigration] is True, showfile migration may be performed which involves writing the migrated
  /// showfile back to the disk, ensure you have approriate write permissions.
  Future<ImportedShowData> loadShowData(
      {String? path, required bool allowMigration}) async {
    Map<String, dynamic>? rawManifest;
    Map<String, dynamic>? rawShowData;
    Map<String, dynamic>? rawSlideData;
    Map<String, dynamic>? rawPlaybackState;

    final ShowStoragePaths showPaths =
        path == null ? _activeShowPaths : ShowStoragePaths(path);

    LoggingManager.instance.storage
        .info('Reading show file from ${showPaths.root.path}');

    final readOperations = [
      // Manifest
      showPaths.manifest
          .readAsString()
          .then((res) => rawManifest = json.decode(res)),
      // Show Data
      showPaths.showData
          .readAsString()
          .then((res) => rawShowData = json.decode(res)),
      // Slide Data
      showPaths.slideData
          .readAsString()
          .then((res) => rawSlideData = json.decode(res)),
      // Playback State
      showPaths.playbackState
          .readAsString()
          .then((res) => rawPlaybackState = json.decode(res)),
    ];

    await Future.wait(readOperations);

    // TODO: We should actually verify the show file Manifest file more thoroughly here. Perhaps look into it for a particular checksum like property.

    final manifest = rawManifest == null
        ? ManifestModel()
        : ManifestModel.fromMap(rawManifest!);
    final showData = rawShowData == null
        ? const ShowDataModel.initial()
        : ShowDataModel.fromMap(rawShowData!);
    final slideData = rawSlideData == null
        ? const SlideDataModel()
        : SlideDataModel.fromMap(rawSlideData!);
    final playbackState = rawPlaybackState == null
        ? const PlaybackStateData.initial()
        : PlaybackStateData.fromMap(rawPlaybackState!);

    final data = ImportedShowData(
        manifest: manifest,
        slideData: slideData,
        showData: showData,
        playbackState: playbackState);

    isWriting = true;
    final migratedData = await migrateShowfileData(
        currentShowData: data,
        manifestFile: showPaths.manifest,
        baseDir: showPaths.root);
    isWriting = false;

    return migratedData;
  }

  /// Unzips and loads the provided [bytes] into the active show directory, overwriting what is already there.
  /// Returns an [ImportedShowData] object once the write has been completed.
  Future<ImportedShowData> loadArchivedShowfile(List<int> bytes) async {
    isReading = true;
    // Delete current active show.
    await deleteActiveShow();

    // Decompress the showfile in an Isolate. This will copy the contents of the archive to the active show dir.
    await decompressShowfile(DecompressShowfileParameters(
      targetDirPath: _activeShowPaths.root.path,
      bytes: bytes,
    ));

    final data = await loadShowData(
        path: _activeShowPaths.root.path, allowMigration: true);
    isReading = false;

    return data;
  }

  Future<void> deleteActiveShow() async {
    isWriting = true;
    LoggingManager.instance.storage.info("Clearing storage");

    final headshots = <FileSystemEntity>[];
    final backgrounds = <FileSystemEntity>[];
    final fonts = <FileSystemEntity>[];
    final images = <FileSystemEntity>[];
    final otherFiles = <FileSystemEntity>[];
    final thumbs = <FileSystemEntity>[];

    await Future.wait([
      // Headshots
      _activeShowPaths.headshots.list().listen((entity) {
        if (entity is File) {
          headshots.add(entity);
        }
      }).asFuture(),
      // Backgrounds
      _activeShowPaths.backgrounds.list().listen((entity) {
        if (entity is File) {
          backgrounds.add(entity);
        }
      }).asFuture(),
      // Fonts
      _activeShowPaths.fonts.list().listen((entity) {
        if (entity is File) {
          fonts.add(entity);
        }
      }).asFuture(),
      // Images
      _activeShowPaths.images.list().listen((entity) {
        if (entity is File) {
          images.add(entity);
        }
      }).asFuture(),
      // Thumbs
      _activeShowPaths.thumbs.list().listen((entity) {
        if (entity is File) {
          thumbs.add(entity);
        }
      }).asFuture(),
      // All other (Non-Directory) Files.
      _activeShowPaths.root.list().listen((entity) {
        if (entity is File) {
          otherFiles.add(entity);
        }
      }).asFuture(),
    ]);

    final headshotDeleteRequests = headshots.map((file) => file.delete());
    final backgroundDeleteRequests = backgrounds.map((file) => file.delete());
    final fontDeleteRequests = fonts.map((file) => file.delete());
    final imagesDeleteRequests = images.map((file) => file.delete());
    final otherFilesDeleteRequests = otherFiles.map((file) => file.delete());
    final thumbsDeleteRequests = thumbs.map((file) => file.delete());

    await Future.wait([
      ...headshotDeleteRequests,
      ...backgroundDeleteRequests,
      ...fontDeleteRequests,
      ...imagesDeleteRequests,
      ...otherFilesDeleteRequests,
      ...thumbsDeleteRequests,
    ]);

    isWriting = false;
    return;
  }

  /// Packages the current contents of the active show directory [_activeShowDir] into an archived file
  ///  and returns a reference to that file.
  ///
  /// Note: **This will nest the .castboard file into a parent Zip archive.** This ensures improved compatiability with
  /// browser downloads*.
  Future<File> archiveActiveShowForExport() async {
    // Retreive the showfile name from the manifest.
    final filename = await getShowfileName(_activeShowPaths.root);

    // Create target .castboard showfile in a temporary staging directory.
    final showfileTarget =
        await File(p.join(_appStoragePaths.archive.path, filename)).create();

    // Archive/Compress the active show into our target file and return the result.
    final innerFile = await archiveShow(_activeShowPaths.root, showfileTarget);

    // Create the targetfile for our zip file.
    final zipFileTarget =
        File(p.join(_appStoragePaths.showExport.path, 'showexport.zip'));
    await zipFileTarget.create();

    await nestShowfile(NestShowfileParameters(
        inputFilePath: innerFile.path, outputFilePath: zipFileTarget.path));

    return zipFileTarget;
  }

  ///
  /// Stages all required show data, compresses (Zips) it and saves it to the file referenced by the targetFile parameter.
  ///
  Future<FileWriteResult> writeCurrentShowToArchive({
    required Map<ActorRef, ActorModel> actors,
    required List<ActorIndexBase> actorIndex,
    required Map<TrackRef, TrackModel> tracks,
    required List<TrackIndexBase> trackIndex,
    required Map<String, TrackRef> trackRefsByName,
    required Map<String, PresetModel> presets,
    required Map<String, SlideModel> slides,
    required SlideOrientation slideOrientation,
    required ManifestModel manifest,
    PlaybackStateData? playbackState,
    required File targetFile,
  }) async {
    // Flag that we are writing to storage.
    isWriting = true;

    LoggingManager.instance.storage
        .info("Preparing to write file to archived storage");

    // Create a Clean staging directory in the System temp location.
    final stagingPaths = await _createCleanShowfileStagingDirectory();

    await Future.wait([
      _stagePlaybackState(stagingPaths.playbackState, playbackState),
      _stageManifest(stagingPaths.manifest, manifest),
      _stageHeadshots(stagingPaths.headshots, actors),
      _stageThumbs(stagingPaths.thumbs, actors),
      _stageBackgrounds(stagingPaths.backgrounds, slides),
      _stageImages(stagingPaths.images, slides),
      _stageFonts(stagingPaths.fonts, manifest.requiredFonts),
      _stageSlideData(
          stagingPaths.slideData,
          SlideDataModel(
            slides: slides,
            slideOrientation: slideOrientation,
          )),
      _stageShowData(stagingPaths.showData, tracks, trackRefsByName, actors,
          actorIndex, trackIndex, presets),
    ]);

    try {
      LoggingManager.instance.storage
          .info("File staging complete. Starting compression");

      await compressShowfile(CompressShowfileParameters(
        sourceDirPath: stagingPaths.root.path,
        targetFilePath: targetFile.path,
      ));

      LoggingManager.instance.storage
          .info("Compression complete, cleaning up Staging directories");

      // Cleanup
      await stagingPaths.root.delete(recursive: true);

      LoggingManager.instance.storage
          .info("Staging Directory cleanup complete");

      isWriting = false;
      return FileWriteResult(true);
    } catch (error) {
      print(error);
      LoggingManager.instance.storage.warning("File compression failed.");
      isWriting = false;
      return FileWriteResult(false, message: 'File compression failed.');
    }
  }

  Future<void> _stagePlaybackState(
    File targetFile,
    PlaybackStateData? playbackState,
  ) async {
    final data = playbackState?.toMap() ?? {};

    final jsonData = json.encoder.convert(data);
    await targetFile.writeAsString(jsonData);
    return;
  }

  Future<void> _stageManifest(
    File targetFile,
    ManifestModel manifest,
  ) async {
    final data = manifest.toMap();

    final jsonData = json.encoder.convert(data);
    await targetFile.writeAsString(jsonData);
    return;
  }

  Future<void> _stageShowData(
      File targetFile,
      Map<TrackRef, TrackModel> tracks,
      Map<String, TrackRef> trackRefsByName,
      Map<ActorRef, ActorModel> actors,
      List<ActorIndexBase> actorIndex,
      List<TrackIndexBase> trackIndex,
      Map<String, PresetModel> presets) async {
    final data = ShowDataModel(
      actors: actors,
      actorIndex: actorIndex,
      trackIndex: trackIndex,
      tracks: tracks,
      trackRefsByName: trackRefsByName,
      presets: presets,
    ).toMap();

    final jsonData = json.encoder.convert(data);
    await targetFile.writeAsString(jsonData);
    return;
  }

  Future<void> _stageSlideData(
      File targetFile, SlideDataModel slideData) async {
    final data = slideData.toMap();
    final jsonData = json.encoder.convert(data);

    await targetFile.writeAsString(jsonData);
    return;
  }

  Future<void> _stageBackgrounds(
      Directory targetDir, Map<String, SlideModel> slides) async {
    final refs = slides.values
        .map((slide) => slide.backgroundRef)
        .where((ref) => ref != const ImageRef.none());

    final requests = refs.map((ref) {
      final sourceFile = getBackgroundFile(ref)!;
      return copyToStagingDir(sourceFile, targetDir);
    });

    await Future.wait(requests);
    return;
  }

  Future<void> _stageImages(
      Directory targetDir, Map<String, SlideModel> slides) async {
    final refs = slides.values
        .map((slide) => extractImageRefs(slide))
        .expand((iter) => iter)
        .toList();

    final requests = refs.map((ref) {
      final sourceFile = getImageFile(ref)!;
      return copyToStagingDir(sourceFile, targetDir);
    });

    await Future.wait(requests);
    return;
  }

  Future<void> _stageFonts(Directory targetDir, List<FontModel> fonts) async {
    final relativePaths = fonts
        .map((font) => font.ref)
        .where((ref) => ref != const FontRef.none());

    final requests = relativePaths.map((ref) {
      final sourceFile = getFontFile(ref)!;
      return copyToStagingDir(sourceFile, targetDir);
    });

    await Future.wait(requests);
    return;
  }

  Future<void> _stageHeadshots(
      Directory targetDir, Map<ActorRef, ActorModel> actors) async {
    final refs = actors.values
        .map((actor) => actor.headshotRef)
        .where((ref) => ref != const ImageRef.none());

    final requests = refs.map((ref) {
      final sourceFile = getHeadshotFile(ref)!;
      return copyToStagingDir(sourceFile, targetDir);
    });

    await Future.wait(requests);
    return;
  }

  Future<void> _stageThumbs(
      Directory targetDir, Map<ActorRef, ActorModel> actors) async {
    final refs = actors.values
        .map((actor) => actor.headshotRef)
        .where((ref) => ref != const ImageRef.none());

    final requests = refs.map((ref) {
      final sourceFile = getThumbnailFile(ref)!;
      return copyToStagingDir(sourceFile, targetDir);
    });

    await Future.wait(requests);
    return;
  }

  String get appRootStoragePath {
    return _appStoragePaths.root.path;
  }

  Future<ShowfileValidationResult> validateShowfile(
      List<int> byteData, int maxFileVersion) async {
    return validateShowfileInternal(byteData, maxFileVersion);
  }

  Future<ShowStoragePaths> _createCleanShowfileStagingDirectory() async {
    LoggingManager.instance.storage.info('Creating Showfile Staging Directory');

    final String systemTempPath = (await getTemporaryDirectoryShim()).path;
    final Directory stagingDir =
        await Directory(p.join(systemTempPath, _stagingDirName)).create();

    LoggingManager.instance.storage
        .info('Showfile Staging Directory created at ${stagingDir.path}');

    final storagePaths = ShowStoragePaths(stagingDir.path);

    LoggingManager.instance.storage
        .info('Resetting Showfile Staging Directory to initial state');

    try {
      await ShowStoragePaths(stagingDir.path).reset();
    } catch (e) {
      LoggingManager.instance.storage.warning(
          'An error occured whilst resetting the Showfile Staging Directory:  $e');
      rethrow;
    }

    LoggingManager.instance.storage
        .info('Fresh Showfile Staging Directory created');
    return storagePaths;
  }

  Future<Directory> decompressGenericZip(
      List<int> byteData, Directory targetDir) async {
    return decompressGenericZipInternal(byteData, targetDir);
  }
}
