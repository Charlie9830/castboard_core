import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

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
import 'package:castboard_core/storage/compressFile.dart';
import 'package:file/memory.dart' as memoryFs;
import 'package:file/local.dart' as localFs;
import 'package:file/file.dart' as fs;

import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/storage/StorageException.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as pathProvider;

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

// Temp Directory Names.
const _headshotsTempDirName = 'headshots';
const _backgroundsTempDirName = 'backgrounds';
const _slideThumbnails = 'slidethumbnails';
const _fontsTempDirName = 'fonts';

// Player Directory Names
const _playerDirName = 'playerfiles';

// Storage root names
const editorStorageRootDirName = "com.charliehall.castboard-editor";
const playerStorageRootDirName =
    "com.charliehall.castboard_player"; // TODO: Why is this underscored but editor is hyphened?

// Player Show File Name.
const _playerCurrentShowFileName = 'currentshow.castboard';

// Staging Directory Base Name.
const _stagingDirName = 'castboard_file_staging';

// Save File Names.
const _headshotsSaveDirName = 'headshots';
const _backgroundsSaveDirName = 'backgrounds';
const _fontsSaveDirName = 'fonts';
const _manifestSaveName = 'manifest.json';
const _slideDataSaveName = 'slidedata.json';
const _showDataSaveName = 'showdata.json';
const _playbackStateSaveName = 'playback_state.json';

enum StorageMode {
  editor,
  player,
}

class Storage {
  static Storage? _instance;
  static bool _initalized = false;

  final Directory? _appStorageRoot;
  final Directory? _headshotsDir;
  final Directory? _backgroundsDir;
  final Directory? _playerDir;
  final Directory? _fontsDir;

  bool isWriting = false;
  bool isReading = false;

  static Storage? get instance {
    if (_initalized == false) {
      throw StorageException(
          'Storage() has not been initialized Yet. Ensure you are calling Storage.initalize() prior to making any other calls');
    }

    return _instance;
  }

  Storage({
    Directory? appStorageRoot,
    Directory? headshots,
    Directory? backgrounds,
    Directory? playerDir,
    Directory? fontsDir,
  })  : _appStorageRoot = appStorageRoot,
        _headshotsDir = headshots,
        _backgroundsDir = backgrounds,
        _playerDir = playerDir,
        _fontsDir = fontsDir;

  static Future<void> initalize(StorageMode mode) async {
    if (_initalized) {
      throw StorageException(
          'Storage is already initalized. Ensure you are only calling Storage.initalize once');
    }

    String appStorageRootDirName = '';
    if (mode == StorageMode.editor) {
      appStorageRootDirName = editorStorageRootDirName;
    } else {
      appStorageRootDirName = playerStorageRootDirName;
    }

    final appStorageRoot = mode == StorageMode.editor
        ? await Directory(p.join(
                (await pathProvider.getTemporaryDirectory()).path,
                appStorageRootDirName))
            .create()
        : await Directory(p.join(
                (await pathProvider.getApplicationDocumentsDirectory()).path,
                appStorageRootDirName))
            .create();

    LoggingManager.instance.storage
        .info("Storage initialized in $mode, path = ${appStorageRoot.path}");

    // Build Directories.
    Directory? headshots;
    Directory? backgrounds;
    Directory? playerDir;
    Directory? fontsDir;
    await Future.wait([
      () async {
        headshots =
            await Directory(p.join(appStorageRoot.path, _headshotsTempDirName))
                .create();
        return;
      }(),
      () async {
        backgrounds = await Directory(
                p.join(appStorageRoot.path, _backgroundsTempDirName))
            .create();
        return;
      }(),
      if (mode == StorageMode.player)
        () async {
          playerDir =
              await Directory(p.join(appStorageRoot.path, _playerDirName))
                  .create();
        }(),
      () async {
        fontsDir =
            await Directory(p.join(appStorageRoot.path, _fontsTempDirName))
                .create();
      }()
    ]);

    _instance = Storage(
        appStorageRoot: appStorageRoot,
        headshots: headshots,
        backgrounds: backgrounds,
        playerDir: playerDir,
        fontsDir: fontsDir);
    _initalized = true;

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
    final Directory headshots = _headshotsDir!;
    final File file = File(p.join(headshots.path, ref.basename));

    if (await file.exists()) {
      await file.delete();
      return;
    }

    return;
  }

  Future<void> deleteFont(FontRef ref) async {
    LoggingManager.instance.storage.info("Deleting Font ${ref.uid}");
    final Directory fonts = _fontsDir!;
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
    final Directory backgrounds = _backgroundsDir!;
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

    return File(
        p.join(_appStorageRoot!.path, _headshotsTempDirName, ref.basename));
  }

  File? getBackgroundFile(PhotoRef ref) {
    if (ref.uid == null || ref.uid!.isEmpty) {
      return null;
    }

    return File(
        p.join(_appStorageRoot!.path, _backgroundsTempDirName, ref.basename));
  }

  File? getFontFile(FontRef ref) {
    return File(
      p.join(_appStorageRoot!.path, _fontsTempDirName, ref.basename),
    );
  }

  Future<void> copyShowFileIntoPlayerStorage(List<int> bytes) async {
    final targetFile = File(p.join(
        _appStorageRoot!.path, _playerDir!.path, _playerCurrentShowFileName));

    LoggingManager.instance.storage
        .info("Copying show file into player storage.");

    await targetFile.writeAsBytes(bytes);
    return;
  }

  Future<bool> isPlayerStoragePopulated() async {
    if (await File(p.join(_playerDir!.path, _playerCurrentShowFileName))
        .exists()) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updatePlayerShowData({
    required Map<String, PresetModel> presets,
    required PlaybackStateData playbackState,
  }) async {
    LoggingManager.instance.storage
        .info("Updating player Show Data.. Reading current show from disk..");
    final onDiskData = await readFromPlayerStorage();

    LoggingManager.instance.storage.info(
        "Writing new show to storage with modified preset and playbackState");
    await writeToPermanentStorage(
        actors: onDiskData.actors,
        tracks: onDiskData.tracks,
        presets: presets,
        slides: onDiskData.slides,
        slideSizeId: onDiskData.slideSizeId,
        slideOrientation: onDiskData.slideOrientation,
        manifest: onDiskData.manifest,
        targetFile: File(p.join(_playerDir!.path, _playerCurrentShowFileName)));

    LoggingManager.instance.storage.info("Show Data update complete");

    return true;
  }

  File getPlayerStorageFile() {
    final file = File(p.join(_playerDir!.path, _playerCurrentShowFileName));

    return file;
  }

  Future<ImportedShowData> readFromPlayerStorage() async {
    final file = File(p.join(_playerDir!.path, _playerCurrentShowFileName));

    LoggingManager.instance.storage
        .info('Reading Player show file from storage. ${file.path}');

    return readFromPermanentStorage(file: file);
  }

  Future<bool> validateShowFile(List<int> byteData) async {
    if (byteData.isEmpty) {
      return false;
    }

    final unzipper = ZipDecoder();
    final archive = unzipper.decodeBytes(byteData);

    // Search for the Manifest.
    final manifestEntityHits =
        archive.where((ArchiveFile entity) => entity.name == _manifestSaveName);

    if (manifestEntityHits.isEmpty) {
      return false;
    }

    final manifestByteData = manifestEntityHits.first.content as List<int>?;

    if (manifestByteData == null || manifestByteData.length == 0) {
      return false;
    }

    final rawManifest = json.decode(utf8.decode(manifestByteData));

    if (rawManifest == null) {
      return false;
    }

    final manifest = ManifestModel.fromMap(rawManifest);

    // TODO: Check Manifest Version.
    return true;
  }

  Future<ImportedShowData> readFromPermanentStorage(
      {required File file}) async {
    isReading = true;
    LoggingManager.instance.storage.info("Opening file ${file.path}");
    if (await file.exists() == false) {
      isReading = false;
      throw FileDoesNotExistException();
    }

    if (p.extension(file.path) != '.castboard') {
      isReading = false;
      throw InvalidFileFormatException();
    }

    // Delete existing Temp Storage.
    await clearStorage();

    final bytes = await file.readAsBytes();
    final unzipper = ZipDecoder();
    final archive = unzipper.decodeBytes(bytes);

    Map<String, dynamic>? rawManifest = {};
    Map<String, dynamic>? rawShowData = {};
    Map<String, dynamic>? rawSlideData = {};
    Map<String, dynamic>? rawPlaybackState = {};
    final fileWriteRequests = <Future<File>>[];

    for (var entity in archive) {
      final name = entity.name;
      final parentDirectoryName =
          p.split(name).isNotEmpty ? p.split(name).first : '';

      // TODO. To extract the files from the directory you compare the parentDirectoryName to the tempDirNames.
      // is this correct? If this is a Save file being unzipped wouldn't it be the saveDirNames?
      // Does this actually get used to decompress saved files or is it intended for the player to read from it's Temp Storage.
      // Should it be made aware of that?

      if (entity.isFile) {
        final byteData = entity.content as List<int>?;
        // Headshots
        if (parentDirectoryName == _headshotsTempDirName) {
          fileWriteRequests.add(
              File(p.join(_headshotsDir!.path, p.basename(name)))
                  .writeAsBytes(byteData!));
        }

        // Backgrounds
        if (parentDirectoryName == _backgroundsTempDirName) {
          fileWriteRequests.add(
              File(p.join(_backgroundsDir!.path, p.basename(name)))
                  .writeAsBytes(byteData!));
        }

        // Fonts
        if (parentDirectoryName == _fontsTempDirName) {
          fileWriteRequests.add(File(p.join(_fontsDir!.path, p.basename(name)))
              .writeAsBytes(byteData!));
        }

        // Manifest
        if (name == _manifestSaveName) {
          rawManifest = json.decode(utf8.decode(byteData!));
        }

        // Show Data (Actors, Tracks, Presets)
        if (name == _showDataSaveName) {
          rawShowData = json.decode(utf8.decode(byteData!));
        }

        // Slide Data (Slides, SlideSize, SlideOrientation)
        if (name == _slideDataSaveName) {
          rawSlideData = json.decode(utf8.decode(byteData!));
        }

        // Playback State (Currently displayed Cast Change etc)
        if (name == _playbackStateSaveName) {
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

  Future<void> clearStorage() async {
    isWriting = true;
    LoggingManager.instance.storage.info("Clearing storage");

    final headshots = <FileSystemEntity>[];
    final backgrounds = <FileSystemEntity>[];
    final fonts = <FileSystemEntity>[];

    await Future.wait([
      // Headshots
      _headshotsDir!.list().listen((entity) {
        if (entity is File) {
          headshots.add(entity);
        }
      }).asFuture(),
      // Backgrounds
      _backgroundsDir!.list().listen((entity) {
        if (entity is File) {
          backgrounds.add(entity);
        }
      }).asFuture(),
      // Fonts
      _fontsDir!.list().listen((entity) {
        if (entity is File) {
          fonts.add(entity);
        }
      }).asFuture()
    ]);

    final headshotDeleteRequests = headshots.map((file) => file.delete());
    final backgroundDeleteRequests = backgrounds.map((file) => file.delete());
    final fontDeleteRequests = fonts.map((file) => file.delete());

    await Future.wait([
      ...headshotDeleteRequests,
      ...backgroundDeleteRequests,
      ...fontDeleteRequests
    ]);

    isWriting = false;
    return;
  }

  ///
  /// Stages all required show data, compresses (Zips) it and saves it to the file referenced by the targetFile parameter.
  ///
  Future<FileWriteResult> writeToPermanentStorage(
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
        .info("Preparing to write file to permanent storage");
    final lfs = localFs.LocalFileSystem();

    // Stage Directories.
    final fs.Directory stagingDir =
        lfs.systemTempDirectory.childDirectory(_stagingDirName);
    if (await stagingDir.exists()) {
      await stagingDir.delete(recursive: true);
    }

    await stagingDir.create();

    await _stagePermStorageDirectories(stagingDir);
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
      await compute(
          compressFile,
          CompressFileParameters(
              targetFilePath: targetFile.path,
              headshotsDirPath: p.join(stagingDir.path, _headshotsSaveDirName),
              backgroundsDirPath:
                  p.join(stagingDir.path, _backgroundsSaveDirName),
              fontsDirPath: p.join(stagingDir.path, _fontsSaveDirName),
              manifestFilePath: p.join(stagingDir.path, _manifestSaveName),
              showDataFilePath: p.join(stagingDir.path, _showDataSaveName),
              playbackStateFilePath:
                  p.join(stagingDir.path, _playbackStateSaveName),
              slideDataFilePath: p.join(stagingDir.path, _slideDataSaveName)),
          debugLabel: 'File Compression Isolate - compressFile()');

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

  Future<void> _stagePlaybackState(
    fs.Directory stagingDir,
    PlaybackStateData? playbackState,
  ) async {
    final data = playbackState?.toMap() ?? {};

    final jsonData = json.encoder.convert(data);
    final targetFile =
        await stagingDir.childFile(_playbackStateSaveName).create();
    await targetFile.writeAsString(jsonData);
    return;
  }

  Future<void> _stageManifest(
    fs.Directory stagingDir,
    ManifestModel manifest,
  ) async {
    final data = manifest.toMap();

    final jsonData = json.encoder.convert(data);
    final targetFile = await stagingDir.childFile(_manifestSaveName).create();
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
    final targetFile = await stagingDir.childFile(_showDataSaveName).create();
    await targetFile.writeAsString(jsonData);
    return;
  }

  Future<void> _stageSlideData(
      fs.Directory stagingDir, SlideDataModel slideData) async {
    final data = slideData.toMap();

    final jsonData = json.encoder.convert(data);

    final targetFile = await stagingDir.childFile(_slideDataSaveName).create();

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
              .childDirectory(_backgroundsSaveDirName)
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
          stagingDir.childDirectory(_fontsSaveDirName).childFile(ref.basename));
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
      return _copyToStagingDir(
          sourceFile,
          stagingDir
              .childDirectory(_headshotsSaveDirName)
              .childFile(ref.basename));
    });

    await Future.wait(requests);
    return;
  }

  Future<void> _stagePermStorageDirectories(fs.Directory dir) async {
    final requests = [
      dir.childDirectory(_headshotsSaveDirName).create(),
      dir.childDirectory(_backgroundsSaveDirName).create(),
      dir.childDirectory(_fontsSaveDirName).create(),
    ];
    await Future.wait(requests);
    return;
  }

  Future<File> _copyToStagingDir(File sourceFile, File targetFile) async {
    await targetFile.create(recursive: true);
    final sourceFileBytes = await sourceFile.readAsBytes();
    return await targetFile.writeAsBytes(sourceFileBytes);
  }
}
