import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:castboard_core/classes/FontRef.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/image_compressor/image_compressor.dart';
import 'package:castboard_core/logging/LoggingManager.dart';
import 'package:castboard_core/models/ActorIndex.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/FontModel.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/playback_state_model.dart';
import 'package:castboard_core/models/SlideSizeModel.dart';
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
import 'package:castboard_core/storage/compression_config.dart';
import 'package:castboard_core/storage/image_processing_error.dart';
import 'package:castboard_core/storage/maybe_compress_headshot.dart';
import 'package:castboard_core/storage/compressShowfile.dart';
import 'package:castboard_core/storage/copyToStagingDirectory.dart';
import 'package:castboard_core/storage/createThumbnail.dart';
import 'package:castboard_core/storage/decompressGenericZipInternal.dart';
import 'package:castboard_core/storage/decompressShowfile.dart';
import 'package:castboard_core/storage/extractImageRefs.dart';
import 'package:castboard_core/storage/getShowfileName.dart';
import 'package:castboard_core/storage/headshot_progress.dart';
import 'package:castboard_core/storage/maybe_compress_image.dart';
import 'package:castboard_core/storage/nestShowfile.dart';
import 'package:castboard_core/storage/showfile_migration/showfileMigration.dart';
import 'package:castboard_core/storage/validateShowfileInternal.dart';
import 'package:castboard_core/version/fileVersion.dart';

import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/storage/StorageException.dart';

import 'package:path/path.dart' as p;

// Storage root names
const designerStorageRootDirName = "com.charliehall.castboard-designer";
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
                  designerStorageRootDirName))
              .create()
          : await Directory(p.join(
                  (await getApplicationSupportDirectoryShim()).path,
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

  File getPerformerSettingsFile() {
    return _appStoragePaths.performerSettingsFile;
  }

  File getPackageUpdateStatusFile() {
    return _appStoragePaths.updateStatusFile;
  }

  Directory getPackageUpdateDirectory() {
    return _appStoragePaths.packageUpdate;
  }

  File getDesignerLastExportSettingsFile() {
    return _appStoragePaths.lastDesignerExportSettingsFile;
  }

  File getBackupFile() {
    return _appStoragePaths.backupFile;
  }

  File getBackupStatusFile() {
    return _appStoragePaths.backupStatus;
  }

  Directory getShowfileTempStorageDirectory() {
    return _appStoragePaths.temp;
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

  Stream<HeadshotProgress> addHeadshots(
      Map<String, String> uidsAndPaths) async* {
    // Initialize the Compressor.
    final compressor = ImageCompressor();
    await compressor.spinUp();

    // Keep track of our progress.
    final int total = uidsAndPaths.length;
    int currentProgress = 0;

    for (var entry in uidsAndPaths.entries) {
      final uid = entry.key;
      final path = entry.value;
      final ext = CompressionConfig.instance
          .headshotExtension; // Image Compressor will encode as jpg file.

      final photo = File(path);

      if (await photo.exists()) {
        Uint8List bytes = await photo.readAsBytes();
        final image = await compressor.decodeImage(bytes);

        if (image.success == false) {
          yield HeadshotProgress(++currentProgress, total,
              error: HeadshotProcessingError(
                uid,
                path,
              ));
          continue;
        }

        try {
          // Compress the image if it's taller then the slide Size.
          if (image.height > const SlideSizeModel.defaultSize().height) {
            bytes = await maybeCompressHeadshot(
              sourceBytes: bytes,
              compressor: compressor,
              maxHeight: CompressionConfig.instance.maxHeadshotHeight,
            );
          }
        } catch (e) {
          yield HeadshotProgress(++currentProgress, total,
              error: HeadshotProcessingError(
                uid,
                path,
              ));
          continue;
        }

        final Directory headshots = _activeShowPaths.headshots;
        await File(p.join(headshots.path, '$uid$ext')).writeAsBytes(bytes);

        yield HeadshotProgress(++currentProgress, total);
      }
    }

    await compressor.spinDown();
  }

  Future<File> addHeadshot(String uid, String path) async {
    LoggingManager.instance.storage.info("Adding headshot from $path");
    final Directory headshots = _activeShowPaths.headshots;
    final ext = CompressionConfig.instance
        .headshotExtension; // Image Compressor will encode as jpg file.

    // Initialize the Compressor.
    final compressor = ImageCompressor();
    await compressor.spinUp();

    final photo = File(path);
    if (await photo.exists()) {
      Uint8List bytes = await photo.readAsBytes();
      final image = await compressor.decodeImage(bytes);

      if (image.success == false) {
        await compressor.spinDown();
        throw ImageProcessingError('Failed to decode image.');
      }

      // Compress the image if it's taller then the slide Size.
      if (image.height > const SlideSizeModel.defaultSize().height) {
        bytes = await maybeCompressHeadshot(
          sourceBytes: bytes,
          compressor: compressor,
          maxHeight: CompressionConfig.instance.maxHeadshotHeight,
        );
      }

      final targetFile =
          await File(p.join(headshots.path, '$uid$ext')).writeAsBytes(bytes);

      // Create and store a thumbnail.
      await createThumbnail(
          sourceFile: targetFile,
          targetFilePath: p.join(_activeShowPaths.thumbs.path, uid));

      await compressor.spinDown();
      return targetFile;
    } else {
      await compressor.spinDown();
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
    final ext = CompressionConfig.instance
        .backgroundExtension; // Image Compressor will encode as jpg file.

    if (await image.exists()) {
      // Instantiate the image compressor.
      final compressor = ImageCompressor();
      await compressor.spinUp();

      Uint8List sourceBytes = await image.readAsBytes();
      sourceBytes = await maybeCompressImage(
          compressor: compressor,
          sourceBytes: sourceBytes,
          maxHeight: CompressionConfig.instance.maxBackgroundHeight,
          maxWidth: CompressionConfig.instance.maxBackgroundWidth,
          ratio: CompressionConfig.instance.backgroundCompressionRatio);

      compressor.spinDown();

      final targetFile =
          await File(p.join(_activeShowPaths.backgrounds.path, '$uid$ext'))
              .writeAsBytes(sourceBytes);

      return targetFile;
    } else {
      throw StorageException('Source Background File does not exist');
    }
  }

  Future<File> addImage(String uid, String path) async {
    LoggingManager.instance.storage.info("Adding Image from $path");
    final imageFile = File(path);
    final ext = CompressionConfig.instance.imageExtension;

    if (await imageFile.exists()) {
      // Instantiate the image compressor.
      final compressor = ImageCompressor();
      await compressor.spinUp();

      Uint8List sourceBytes = await imageFile.readAsBytes();
      sourceBytes = await maybeCompressImage(
          compressor: compressor,
          sourceBytes: sourceBytes,
          maxHeight: CompressionConfig.instance.maxImageHeight,
          maxWidth: CompressionConfig.instance.maxImageWidth,
          ratio: CompressionConfig.instance.imageCompressionRatio);

      compressor.spinDown();

      final targetFile =
          await File(p.join(_activeShowPaths.images.path, '$uid$ext'))
              .writeAsBytes(sourceBytes);

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

  File? getThumbnailFile(ImageRef ref, {bool withoutExtension = false}) {
    if (ref.uid == null || ref.uid!.isEmpty) {
      return null;
    }

    return File(p.join(_activeShowPaths.thumbs.path, ref.uid) +
        (withoutExtension ? '' : kThumbnailFileExt));
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
    required PlaybackStateModel playbackState,
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
        ? const PlaybackStateModel.initial()
        : PlaybackStateModel.fromMap(rawPlaybackState!);

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
    PlaybackStateModel? playbackState,
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
    } catch (error, stacktrace) {
      LoggingManager.instance.storage
          .warning("File compression failed", error, stacktrace);
      isWriting = false;
      return FileWriteResult(false, message: 'File compression failed.');
    }
  }

  Future<void> _stagePlaybackState(
    File targetFile,
    PlaybackStateModel? playbackState,
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

    try {
      await Future.wait(requests);
    } on FileSystemException catch (e) {
      if (e.osError != null && e.osError!.errorCode == 2) {
        // The system cannot find the file specified. Actor Thumbnails aren't vital to the showfile so we shouldn't block execution because of this.
        LoggingManager.instance.storage.warning(
            'A thumbnail could not be located when saving the showfile. ${e.message}');
      }
    }

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

  /// Extracts a castboard showfile from within a Zip archive. This usually occurs when a file has been
  /// downloaded from performer.
  Future<Uint8List> extractNestedShowfile(Uint8List data) async {
    final targetDir = Directory(
        p.join(_appStoragePaths.temp.path, 'downloaded_showfile_buffer'));
    if (await targetDir.exists()) {
      await targetDir.delete(recursive: true);
    }

    await targetDir.create();

    await decompressGenericZip(data, targetDir);

    File? targetFile;
    await for (final entity in targetDir.list()) {
      if (entity.path.endsWith('.castboard')) {
        targetFile = File(entity.path);
        continue;
      }
    }

    if (targetFile == null || await targetFile.exists() == false) {
      throw 'An error occured in extractNestedShowfile. Unable to locate .castboard file';
    }

    final bytes = await targetFile.readAsBytes();
    return bytes;
  }
}
