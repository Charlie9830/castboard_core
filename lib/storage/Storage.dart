import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:castboard_core/classes/FontRef.dart';
import 'package:castboard_core/enums.dart';
import 'package:castboard_core/logging/LoggingManager.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/FontModel.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/RemoteCastChangeData.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/storage/Exceptions.dart';
import 'package:castboard_core/storage/FileWriteResult.dart';
import 'package:castboard_core/storage/ImportedShowData.dart';
import 'package:castboard_core/models/ShowDataModel.dart';
import 'package:castboard_core/storage/SlideDataModel.dart';
import 'package:castboard_core/storage/compressFileWorker.dart';
import 'package:castboard_core/storage/getParentDirectoryName.dart';
import 'package:castboard_core/storage/validateManifest.dart';
import 'package:file/local.dart'
    as localFs; // TODO: Do we need this package anymore?
import 'package:file/file.dart' as fs;

import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/storage/StorageException.dart';
import 'package:flutter/foundation.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as pathProvider;

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

// Storage root names
const editorStorageRootDirName = "com.charliehall.castboard-editor";
const playerStorageRootDirName =
    "com.charliehall.castboard_player"; // TODO: Why is this underscored but editor is hyphened?
const _archiveDirName = 'archive';
const _activeShowDirName = 'active';

// Staging Directory Base Name.
const _stagingDirName = 'castboard_file_staging';

// Save File Names.
const _headshotsDirName = 'headshots';
const _backgroundsDirName = 'backgrounds';
const _fontsDirName = 'fonts';
const _manifestFileName = 'manifest.json';
const _slideDataFileName = 'slidedata.json';
const _showDataFileName = 'showdata.json';
const _playbackStateFileName = 'playback_state.json';

enum StorageMode {
  editor,
  player,
}

class Storage {
  static Storage? _instance;
  static bool _initialized = false;

  final Directory _rootDir;
  final Directory _archiveDir;
  final Directory _activeShowDir;
  final Directory _headshotsDir;
  final Directory _backgroundsDir;
  final Directory _fontsDir;

  bool isWriting = false;
  bool isReading = false;

  static Storage get instance {
    if (_initialized == false || _instance == null) {
      throw StorageException(
          'Storage() has not been initialized Yet. Ensure you are calling Storage.initalize() prior to making any other calls');
    }

    return _instance!;
  }

  Storage({
    required Directory rootDir,
    required Directory headshots,
    required Directory backgrounds,
    required Directory archiveDir,
    required Directory fontsDir,
    required Directory activeShowDir,
  })  : _rootDir = rootDir,
        _headshotsDir = headshots,
        _backgroundsDir = backgrounds,
        _fontsDir = fontsDir,
        _archiveDir = archiveDir,
        _activeShowDir = activeShowDir;

  static Future<void> initialize(StorageMode mode) async {
    if (_initialized) {
      throw StorageException(
          'Storage is already initalized. Ensure you are only calling Storage.initialize once');
    }

    // Create a the root storage directory. Use the correct App name based on if we are running inside the editor or the
    // player.
    late Directory rootDir;
    try {
      rootDir = mode == StorageMode.editor
          ? await Directory(p.join(
                  (await pathProvider.getTemporaryDirectory()).path,
                  editorStorageRootDirName))
              .create()
          : await Directory(p.join(
                  (await pathProvider.getApplicationDocumentsDirectory()).path,
                  playerStorageRootDirName))
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

    // Build the directories and assert their existence.
    late Directory archiveDir;
    late Directory activeShowDir;

    try {
      // Create the archive and activeShowDir first, these are the parents of all following directories.
      await Future.wait([
        // Active Show Directory.
        () async {
          activeShowDir =
              await Directory(p.join(rootDir.path, _activeShowDirName))
                  .create();
        }(),

        // Archived Show Directory.
        () async {
          archiveDir =
              await Directory(p.join(rootDir.path, _archiveDirName)).create();
        }()
      ]);
    } catch (e, stacktrace) {
      LoggingManager.instance.storage.severe(
          'An error occured whilst creating the Active Show Directory or the Archive Directory',
          e,
          stacktrace);
    }

    // Create the remaining sub directories.
    Directory? headshots;
    Directory? backgrounds;
    Directory? fontsDir;

    try {
      await Future.wait([
        // Headshots
        () async {
          headshots =
              await Directory(p.join(activeShowDir.path, _headshotsDirName))
                  .create();
          return;
        }(),
        // Backgrounds
        () async {
          backgrounds =
              await Directory(p.join(activeShowDir.path, _backgroundsDirName))
                  .create();
          return;
        }(),
        // Fonts
        () async {
          fontsDir = await Directory(p.join(activeShowDir.path, _fontsDirName))
              .create();
        }()
      ]);
    } catch (e, stacktrace) {
      LoggingManager.instance.storage.severe(
          'An error occured whilst creating one of the storage sub directories. ',
          e,
          stacktrace);
    }

    _instance = Storage(
      rootDir: rootDir,
      activeShowDir: activeShowDir,
      archiveDir: archiveDir,
      headshots: headshots!,
      backgrounds: backgrounds!,
      fontsDir: fontsDir!,
    );
    _initialized = true;

    LoggingManager.instance.storage
        .info("Storage initialization completed succesfully");
  }

  Future<File> addFont(String uid, String path) async {
    LoggingManager.instance.server.info("Adding font from $path");
    final Directory? fonts = _fontsDir;

    final font = File(path);
    if (await font.exists()) {
      final ext = p.extension(path);
      final targetFile = await font.copy(p.join(fonts!.path, '$uid$ext'));

      return targetFile;
    } else {
      throw StorageException('Source Font file does not exist');
    }
  }

  Future<File> addHeadshot(String uid, String path) async {
    LoggingManager.instance.storage.info("Adding headshot from $path");
    final Directory? headshots = _headshotsDir;

    final photo = File(path);
    if (await photo.exists()) {
      final ext = p.extension(path);
      final targetFile = await photo.copy(p.join(headshots!.path, '$uid$ext'));

      return targetFile;
    } else {
      throw StorageException('Source Photo File does not exist');
    }
  }

  Future<void> updateHeadshot(
      PhotoRef current, String newId, File newHeadshot) async {
    LoggingManager.instance.storage
        .info("Updating headshot ${current.uid} to $newId");
    await addHeadshot(newId, newHeadshot.path);
    await deleteHeadshot(current);

    return;
  }

  Future<void> deleteHeadshot(PhotoRef ref) async {
    LoggingManager.instance.storage.info("Deleting Headshot ${ref.uid}");
    final Directory headshots = _headshotsDir;
    final File file = File(p.join(headshots.path, ref.basename));

    if (await file.exists()) {
      await file.delete();
      return;
    }

    return;
  }

  Future<void> deleteFont(FontRef ref) async {
    LoggingManager.instance.storage.info("Deleting Font ${ref.uid}");
    final Directory fonts = _fontsDir;
    final File file = File(p.join(fonts.path, ref.basename));

    if (await file.exists()) {
      await file.delete();
      return;
    }

    return;
  }

  Future<File> addBackground(String uid, String path) async {
    LoggingManager.instance.storage.info("Adding background from $path");
    final Directory? backgrounds = _backgroundsDir;

    final photo = File(path);
    if (await photo.exists()) {
      final ext = p.extension(path);
      final targetFile =
          await photo.copy(p.join(backgrounds!.path, '$uid$ext'));

      return targetFile;
    } else {
      throw StorageException('Source Background File does not exist');
    }
  }

  Future<void> updateBackground(
      PhotoRef current, String newId, File newBackground) async {
    LoggingManager.instance.storage
        .info("Updating background from ${current.uid} to $newId");
    await addBackground(newId, newBackground.path);
    await deleteBackground(current);

    return;
  }

  Future<void> deleteBackground(PhotoRef ref) async {
    LoggingManager.instance.storage.info("Deleting background ${ref.uid}");
    final Directory backgrounds = _backgroundsDir;
    final File file = File(p.join(backgrounds.path, ref.basename));

    if (await file.exists()) {
      await file.delete();
      return;
    }

    return;
  }

  File? getHeadshotFile(PhotoRef ref) {
    if (ref.uid == null || ref.uid!.isEmpty) {
      return null;
    }

    return File(p.join(_headshotsDir.path, ref.basename));
  }

  File? getBackgroundFile(PhotoRef ref) {
    if (ref.uid == null || ref.uid!.isEmpty) {
      return null;
    }

    return File(p.join(_backgroundsDir.path, ref.basename));
  }

  File? getFontFile(FontRef ref) {
    return File(
      p.join(_fontsDir.path, ref.basename),
    );
  }

  /// Checks that a showfile Manifest file exists and it is not empty is the player storage directory (Not the Archive directory)
  Future<bool> isPlayerStoragePopulated() async {
    final manifestFile = File(p.join(_activeShowDir.path, _manifestFileName));
    return await manifestFile.exists() &&
        (await manifestFile.readAsString()).isNotEmpty;
  }

  Future<bool> updatePlayerShowData({
    required ShowDataModel showData,
    required PlaybackStateData playbackState,
  }) async {
    LoggingManager.instance.storage.info("Updating player show data");

    final showDataFile = File(p.join(_activeShowDir.path, _showDataFileName));
    final playbackStateFile =
        File(p.join(_activeShowDir.path, _playbackStateFileName));

    final writeOperations = [
      showDataFile.writeAsString(json.encode(showData.toMap())),
      playbackStateFile.writeAsString(json.encode(playbackState.toMap()))
    ];

    try {
      await Future.wait(writeOperations);
      return true;
    } catch (e) {
      LoggingManager.instance.storage.severe(
          "Something went wrong whilst during a call to updatePlayerShowData, \n ${e.toString()}");
      return false;
    }
  }

  Future<ImportedShowData> readActiveShow() async {
    LoggingManager.instance.storage
        .info('Reading active show file from storage');

    Map<String, dynamic>? rawManifest;
    Map<String, dynamic>? rawShowData;
    Map<String, dynamic>? rawSlideData;
    Map<String, dynamic>? rawPlaybackState;

    final baseDirPath = _activeShowDir.path;
    final readOperations = [
      // Manifest
      File(p.join(baseDirPath, _manifestFileName))
          .readAsString()
          .then((res) => rawManifest = json.decode(res)),
      // Show Data
      File(p.join(baseDirPath, _showDataFileName))
          .readAsString()
          .then((res) => rawShowData = json.decode(res)),
      // Slide Data
      File(p.join(baseDirPath, _slideDataFileName))
          .readAsString()
          .then((res) => rawSlideData = json.decode(res)),
      // Playback State
      File(p.join(baseDirPath, _playbackStateFileName))
          .readAsString()
          .then((res) => rawPlaybackState = json.decode(res)),
    ];

    await Future.wait(readOperations);

    // TODO: We should actually verify the show file Manifest file more thoroughly here. Perhaps look into it for a particular checksum like property.

    final manifest = ManifestModel.fromMap(rawManifest ?? {});
    final showData = ShowDataModel.fromMap(rawShowData);
    final slideData = SlideDataModel.fromMap(rawSlideData ?? {});
    final playbackState = PlaybackStateData.fromMap(rawPlaybackState);

    return ImportedShowData(
      manifest: manifest,
      actors: showData.actors,
      tracks: showData.tracks,
      presets: showData.presets,
      playbackState: playbackState,
      slides: slideData.slides,
      slideOrientation: slideData.slideOrientation,
      slideSizeId: slideData.slideSizeId,
    );
  }

  Future<bool> validateShowFile(List<int> byteData) async {
    // TODO: This could be done in a seperate Thread.
    if (byteData.isEmpty) {
      LoggingManager.instance.storage
          .warning('Showfile validation failed due to byteData being empty.');
      return false;
    }

    final unzipper = ZipDecoder();
    final archive = unzipper.decodeBytes(byteData);

    // Search for the Manifest.
    final manifestEntityHits =
        archive.where((ArchiveFile entity) => entity.name == _manifestFileName);

    if (manifestEntityHits.isEmpty) {
      LoggingManager.instance.storage
          .warning('Showfile validation failed due to no Manifest found.');
      return false;
    }

    final manifestByteData = manifestEntityHits.first.content as List<int>?;

    if (manifestByteData == null || manifestByteData.length == 0) {
      LoggingManager.instance.storage.warning(
          'Showfile validation failed due to manifestByteData being null or empty.');
      return false;
    }

    final rawManifest = json.decode(utf8.decode(manifestByteData));

    if (rawManifest == null) {
      LoggingManager.instance.storage
          .warning('Showfile validation failed due rawManifest being null.');
      return false;
    }

    final manifest = ManifestModel.fromMap(rawManifest);

    return validateManifest(manifest);
  }

  /// Unzips and loads the provided [bytes] into the active show directory, overwriting what is already there.
  /// Returns an [ImportedShowData] object once the write has been completed.
  Future<ImportedShowData> loadArchivedShowfile(List<int> bytes) async {
    isReading = true;
    // Delete current active show.
    await deleteActiveShow();

    // Decode the Zip File
    final unzipper = ZipDecoder();
    final archive = unzipper.decodeBytes(bytes);

    Map<String, dynamic>? rawManifest = {};
    Map<String, dynamic>? rawShowData = {};
    Map<String, dynamic>? rawSlideData = {};
    Map<String, dynamic>? rawPlaybackState = {};
    final fileWriteRequests = <Future<File>>[];

    for (var entity in archive) {
      final name = entity.name;
      final parentDirectoryName = getParentDirectoryName(name);

      if (entity.isFile) {
        final byteData = entity.content as List<int>?;
        // Headshots
        if (parentDirectoryName == _headshotsDirName) {
          fileWriteRequests.add(
              File(p.join(_headshotsDir.path, p.basename(name)))
                  .writeAsBytes(byteData!));
        }

        // Backgrounds
        if (parentDirectoryName == _backgroundsDirName) {
          fileWriteRequests.add(
              File(p.join(_backgroundsDir.path, p.basename(name)))
                  .writeAsBytes(byteData!));
        }

        // Fonts
        if (parentDirectoryName == _fontsDirName) {
          fileWriteRequests.add(File(p.join(_fontsDir.path, p.basename(name)))
              .writeAsBytes(byteData!));
        }

        // Manifest
        if (name == _manifestFileName) {
          rawManifest = json.decode(utf8.decode(byteData!));
        }

        // Show Data (Actors, Tracks, Presets)
        if (name == _showDataFileName) {
          rawShowData = json.decode(utf8.decode(byteData!));
        }

        // Slide Data (Slides, SlideSize, SlideOrientation)
        if (name == _slideDataFileName) {
          rawSlideData = json.decode(utf8.decode(byteData!));
        }

        // Playback State (Currently displayed Cast Change etc)
        if (name == _playbackStateFileName) {
          rawPlaybackState = json.decode(utf8.decode(byteData!));
        }
      }
    }

    await Future.wait(fileWriteRequests);

    final manifestData = rawManifest == null
        ? ManifestModel()
        : ManifestModel.fromMap(rawManifest);
    final showData = rawShowData == null
        ? ShowDataModel()
        : ShowDataModel.fromMap(rawShowData);
    final slideData = rawSlideData == null
        ? SlideDataModel()
        : SlideDataModel.fromMap(rawSlideData);
    final playbackState = rawPlaybackState == null
        ? PlaybackStateData.initial()
        : PlaybackStateData.fromMap(rawPlaybackState);

    isReading = false;

    // TODO: Verification and Coercion. Values or behaviour for ImportedShowData if properties are Null.
    // -> Coerce a default Preset into existence if not already existing.
    // -> If the Manifest is null, something bad has probalby happened. Should notify the user.
    return ImportedShowData(
      manifest: manifestData,
      actors: showData.actors,
      tracks: showData.tracks,
      presets: showData.presets,
      slides: slideData.slides,
      slideSizeId: slideData.slideSizeId,
      slideOrientation: slideData.slideOrientation,
      playbackState: playbackState,
    );
  }

  Future<void> deleteActiveShow() async {
    isWriting = true;
    LoggingManager.instance.storage.info("Clearing storage");

    final headshots = <FileSystemEntity>[];
    final backgrounds = <FileSystemEntity>[];
    final fonts = <FileSystemEntity>[];
    final otherFiles = <FileSystemEntity>[];

    await Future.wait([
      // Headshots
      _headshotsDir.list().listen((entity) {
        if (entity is File) {
          headshots.add(entity);
        }
      }).asFuture(),
      // Backgrounds
      _backgroundsDir.list().listen((entity) {
        if (entity is File) {
          backgrounds.add(entity);
        }
      }).asFuture(),
      // Fonts
      _fontsDir.list().listen((entity) {
        if (entity is File) {
          fonts.add(entity);
        }
      }).asFuture(),
      // All other (Non-Directory) Files.
      _activeShowDir.list().listen((entity) {
        if (entity is File) {
          otherFiles.add(entity);
        }
      }).asFuture(),
    ]);

    final headshotDeleteRequests = headshots.map((file) => file.delete());
    final backgroundDeleteRequests = backgrounds.map((file) => file.delete());
    final fontDeleteRequests = fonts.map((file) => file.delete());
    final otherFilesDeleteRequests = otherFiles.map((file) => file.delete());

    await Future.wait([
      ...headshotDeleteRequests,
      ...backgroundDeleteRequests,
      ...fontDeleteRequests,
      ...otherFilesDeleteRequests,
    ]);

    isWriting = false;
    return;
  }

  Future<String> _getShowfileName(Directory showfile) async {
    const unknownFileName = 'Show.castboard';
    final manifestFile = File(p.join(showfile.path, _manifestFileName));

    if (await manifestFile.exists() == false) {
      LoggingManager.instance.storage.warning(
          'Failed to retrieve showfile name from manifest. Using default.');
      return unknownFileName;
    }

    try {
      final rawData = json.decode(await manifestFile.readAsString());
      final manifest = ManifestModel.fromMap(rawData);

      return '${manifest.fileName}.castboard';
    } catch (e, stacktrace) {
      LoggingManager.instance.storage.warning(
          'Failed to retrieve showfile name from manifest. Using default.',
          e,
          stacktrace);
      return unknownFileName;
    }
  }

  /// Packages the current contents of the active show directory [_activeShowDir] into an archived file
  ///  and returns a reference to that file.
  Future<File> archiveActiveShow() async {
    // Retreive the showfile name from the manifest.
    final filename = await _getShowfileName(_activeShowDir);

    // Create the target file into the archive directory.
    final targetFile = await File(p.join(_archiveDir.path, filename)).create();

    // Archive/Compress the active show into our target file and return the result.
    return await _archiveShow(_activeShowDir, targetFile);
  }

  /// Archives the show file provided by [source] to the file reference provided by [target]
  Future<File> _archiveShow(Directory source, File target) async {
    if (await source.exists() == false) {
      throw ArgumentError('Source directory does not exist', 'source');
    }

    final basePath = source.path;
    final joinWith = (String subDir) => p.join(basePath, subDir);

    await _compressFile(CompressFileParameters(
      backgroundsDirPath: joinWith(_backgroundsDirName),
      fontsDirPath: joinWith(_fontsDirName),
      headshotsDirPath: joinWith(_headshotsDirName),
      manifestFilePath: joinWith(_manifestFileName),
      playbackStateFilePath: joinWith(_playbackStateFileName),
      showDataFilePath: joinWith(_showDataFileName),
      slideDataFilePath: joinWith(_slideDataFileName),
      targetFilePath: target.path,
    ));

    return target;
  }

  ///
  /// Stages all required show data, compresses (Zips) it and saves it to the file referenced by the targetFile parameter.
  ///
  Future<FileWriteResult> writeCurrentShowToArchive(
      {required Map<ActorRef, ActorModel> actors,
      required Map<TrackRef, TrackModel> tracks,
      required Map<String, PresetModel> presets,
      required Map<String, SlideModel> slides,
      required String slideSizeId,
      required SlideOrientation slideOrientation,
      required ManifestModel manifest,
      PlaybackStateData? playbackState,
      required File targetFile}) async {
    // Flag that we are writing to storage.
    isWriting = true;

    LoggingManager.instance.storage
        .info("Preparing to write file to archived storage");
    final lfs = localFs.LocalFileSystem();

    // Stage Directories.
    final fs.Directory stagingDir =
        lfs.systemTempDirectory.childDirectory(_stagingDirName);
    if (await stagingDir.exists()) {
      await stagingDir.delete(recursive: true);
    }

    await stagingDir.create();

    await _stageArchivedStorageDirectories(stagingDir);
    await Future.wait([
      _stagePlaybackState(stagingDir, playbackState),
      _stageManifest(stagingDir, manifest),
      _stageHeadshots(stagingDir, actors),
      _stageBackgrounds(stagingDir, slides),
      _stageSlideData(
          stagingDir,
          SlideDataModel(
            slides: slides,
            slideSizeId: slideSizeId,
            slideOrientation: slideOrientation,
          )),
      _stageShowData(stagingDir, tracks, actors, presets),
      _stageFonts(stagingDir, manifest.requiredFonts),
    ]);

    try {
      LoggingManager.instance.storage
          .info("File staging complete. Beginning compression");
      await _compressFile(CompressFileParameters(
          targetFilePath: targetFile.path,
          headshotsDirPath: p.join(stagingDir.path, _headshotsDirName),
          backgroundsDirPath: p.join(stagingDir.path, _backgroundsDirName),
          fontsDirPath: p.join(stagingDir.path, _fontsDirName),
          manifestFilePath: p.join(stagingDir.path, _manifestFileName),
          showDataFilePath: p.join(stagingDir.path, _showDataFileName),
          playbackStateFilePath:
              p.join(stagingDir.path, _playbackStateFileName),
          slideDataFilePath: p.join(stagingDir.path, _slideDataFileName)));

      LoggingManager.instance.storage
          .info("Compression complete, cleaning up Staging directories");

      // Cleanup
      await stagingDir.delete(recursive: true);

      LoggingManager.instance.storage
          .info("Staging Directory cleanup complete");

      isWriting = false;
      return FileWriteResult(true);
    } catch (error) {
      LoggingManager.instance.storage.warning("File compression failed.");
      isWriting = false;
      return FileWriteResult(false, message: 'File compression failed.');
    }
  }

  Future<void> _compressFile(CompressFileParameters params) async {
    try {
      await compute(compressFileWorker, params,
          debugLabel: 'File Compression Isolate - compressFile()');
    } catch (e, stacktrace) {
      LoggingManager.instance.storage
          .severe('Failure during file compression/archival', e, stacktrace);
    }
  }

  Future<void> _stagePlaybackState(
    fs.Directory stagingDir,
    PlaybackStateData? playbackState,
  ) async {
    final data = playbackState?.toMap() ?? {};

    final jsonData = json.encoder.convert(data);
    final targetFile =
        await stagingDir.childFile(_playbackStateFileName).create();
    await targetFile.writeAsString(jsonData);
    return;
  }

  Future<void> _stageManifest(
    fs.Directory stagingDir,
    ManifestModel manifest,
  ) async {
    final data = manifest.toMap();

    final jsonData = json.encoder.convert(data);
    final targetFile = await stagingDir.childFile(_manifestFileName).create();
    await targetFile.writeAsString(jsonData);
    return;
  }

  Future<void> _stageShowData(
      fs.Directory stagingDir,
      Map<TrackRef, TrackModel> tracks,
      Map<ActorRef, ActorModel> actors,
      Map<String, PresetModel> presets) async {
    final data = ShowDataModel(
      actors: actors,
      tracks: tracks,
      presets: presets,
    ).toMap();

    final jsonData = json.encoder.convert(data);
    final targetFile = await stagingDir.childFile(_showDataFileName).create();
    await targetFile.writeAsString(jsonData);
    return;
  }

  Future<void> _stageSlideData(
      fs.Directory stagingDir, SlideDataModel slideData) async {
    final data = slideData.toMap();

    final jsonData = json.encoder.convert(data);

    final targetFile = await stagingDir.childFile(_slideDataFileName).create();

    await targetFile.writeAsString(jsonData);
    return;
  }

  Future<void> _stageBackgrounds(
      fs.Directory stagingDir, Map<String, SlideModel> slides) async {
    final refs = slides.values
        .map((slide) => slide.backgroundRef)
        .where((ref) => ref != PhotoRef.none());

    final requests = refs.map((ref) {
      final sourceFile = getBackgroundFile(ref)!;
      return _copyToStagingDir(
          sourceFile,
          stagingDir
              .childDirectory(_backgroundsDirName)
              .childFile(ref.basename));
    });

    await Future.wait(requests);
    return;
  }

  Future<void> _stageFonts(
      fs.Directory stagingDir, List<FontModel> fonts) async {
    final relativePaths =
        fonts.map((font) => font.ref).where((ref) => ref != FontRef.none());

    final requests = relativePaths.map((ref) {
      final sourceFile = getFontFile(ref)!;
      return _copyToStagingDir(sourceFile,
          stagingDir.childDirectory(_fontsDirName).childFile(ref.basename));
    });

    await Future.wait(requests);
    return;
  }

  Future<void> _stageHeadshots(
      fs.Directory stagingDir, Map<ActorRef, ActorModel> actors) async {
    final refs = actors.values
        .map((actor) => actor.headshotRef)
        .where((ref) => ref != PhotoRef.none());

    final requests = refs.map((ref) {
      final sourceFile = getHeadshotFile(ref)!;
      return _copyToStagingDir(sourceFile,
          stagingDir.childDirectory(_headshotsDirName).childFile(ref.basename));
    });

    await Future.wait(requests);
    return;
  }

  Future<void> _stageArchivedStorageDirectories(fs.Directory dir) async {
    final requests = [
      dir.childDirectory(_headshotsDirName).create(),
      dir.childDirectory(_backgroundsDirName).create(),
      dir.childDirectory(_fontsDirName).create(),
    ];
    await Future.wait(requests);
    return;
  }

  Future<File> _copyToStagingDir(File sourceFile, File targetFile) async {
    await targetFile.create(recursive: true);
    final sourceFileBytes = await sourceFile.readAsBytes();
    return await targetFile.writeAsBytes(sourceFileBytes);
  }

  String get appRootStoragePath {
    return _rootDir.path;
  }
}
