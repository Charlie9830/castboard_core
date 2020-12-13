import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/RoleModel.dart';
import 'package:castboard_core/models/SlideModel.dart';
import 'package:castboard_core/storage/Exceptions.dart';
import 'package:castboard_core/storage/ImportedShowData.dart';
import 'package:file/memory.dart' as memoryFs;

import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/storage/StorageException.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as pathProvider;

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

// Temp Directory Names.
const _headshotsTempDirName = 'headshots';
const _backgroundsTempDirName = 'backgrounds';
const _slideThumbnails = 'slidethumbnails';

// Player Directory Names
const _playerDirName = 'playerfiles';

// Player Show File Name.
const _playerCurrentShowFileName = 'currentshow.castboard';

// Save File Names.
const _headshotsSaveDirName = 'headshots';
const _backgroundsSaveDirName = 'backgrounds';
const _manifestSaveName = 'manifest.json';
const _slideDataSaveName = 'slidedata.json';
const _showDataSaveName = 'showdata.json';

enum StorageMode {
  editor,
  player,
}

class Storage {
  static Storage _instance;
  static bool _initalized = false;

  final Directory _appStorageRoot;
  final Directory _headshotsDir;
  final Directory _backgroundsDir;
  final Directory _playerDir;

  static Storage get instance {
    if (_initalized == false) {
      throw StorageException(
          'Storage() as not been initialized Yet. Ensure you are calling Storage.initalize() prior to making any other calls');
    }

    return _instance;
  }

  Storage(
      {Directory appStorageRoot,
      Directory headshots,
      Directory backgrounds,
      Directory playerDir})
      : _appStorageRoot = appStorageRoot,
        _headshotsDir = headshots,
        _backgroundsDir = backgrounds,
        _playerDir = playerDir;

  static Future<void> initalize(StorageMode mode) async {
    if (_initalized) {
      throw StorageException(
          'Storage is already initalized. Ensure you are only calling Storage.initalize once');
    }

    String appStorageRootDirName = '';
    if (mode == StorageMode.editor) {
      appStorageRootDirName = 'com.charliehall.castboard-editor';
    } else {
      appStorageRootDirName = 'com.charliehall.castboard_player';
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

    // Build Directories.
    Directory headshots;
    Directory backgrounds;
    Directory playerDir;
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
        }()
    ]);

    _instance = Storage(
        appStorageRoot: appStorageRoot,
        headshots: headshots,
        backgrounds: backgrounds,
        playerDir: playerDir);
    _initalized = true;
  }

  Future<File> addHeadshot(String uid, String path) async {
    final Directory headshots = _headshotsDir;

    final photo = File(path);
    if (await photo.exists()) {
      final extension = p.extension(path);
      final targetFile =
          await photo.copy(p.join(headshots.path, '$uid$extension'));

      return targetFile;
    } else {
      throw StorageException('Source Photo File does not exist');
    }
  }

  Future<void> updateHeadshot(
      PhotoRef current, String newId, File newHeadshot) async {
    await addHeadshot(newId, newHeadshot.path);
    await deleteHeadshot(current);

    return;
  }

  Future<void> deleteHeadshot(PhotoRef ref) async {
    final Directory headshots = _headshotsDir;
    final File file = File(p.join(headshots.path, ref.basename));

    if (await file.exists()) {
      await file.delete();
      return;
    }

    return;
  }

  Future<File> addBackground(String uid, String path) async {
    final Directory backgrounds = _backgroundsDir;

    final photo = File(path);
    if (await photo.exists()) {
      final extension = p.extension(path);
      final targetFile =
          await photo.copy(p.join(backgrounds.path, '$uid$extension'));

      return targetFile;
    } else {
      throw StorageException('Source Background File does not exist');
    }
  }

  Future<void> updateBackground(
      PhotoRef current, String newId, File newBackground) async {
    await addBackground(newId, newBackground.path);
    await deleteBackground(current);

    return;
  }

  Future<void> deleteBackground(PhotoRef ref) async {
    final Directory backgrounds = _backgroundsDir;
    final File file = File(p.join(backgrounds.path, ref.basename));

    if (await file.exists()) {
      await file.delete();
      return;
    }

    return;
  }

  File getHeadshotFile(PhotoRef ref) {
    if (ref == null) {
      return null;
    }

    if (ref.uid == null || ref.uid.isEmpty) {
      return null;
    }

    return File(
        p.join(_appStorageRoot.path, _headshotsTempDirName, ref.basename));
  }

  File getBackgroundFile(PhotoRef ref) {
    if (ref == null) {
      return null;
    }

    if (ref.uid == null || ref.uid.isEmpty) {
      return null;
    }

    return File(
        p.join(_appStorageRoot.path, _backgroundsTempDirName, ref.basename));
  }

  Future<void> copyShowFileIntoPlayerStorage(List<int> bytes) async {
    final targetFile = File(p.join(
        _appStorageRoot.path, _playerDir.path, _playerCurrentShowFileName));

    await targetFile.writeAsBytes(bytes);
    return;
  }

  Future<bool> isPlayerStoragePopulated() async {
    if (await File(p.join(_playerDir.path, _playerCurrentShowFileName))
        .exists()) {
      return true;
    } else {
      return false;
    }
  }

  Future<ImportedShowData> readFromPlayerStorage() async {
    final file = File(p.join(_playerDir.path, _playerCurrentShowFileName));

    return readFromPermanentStorage(file: file);
  }

  Future<ImportedShowData> readFromPermanentStorage(
      {@required File file}) async {
    if (file == null) {
      throw ArgumentError('File argument must not be null');
    }

    if (await file.exists() == false) {
      throw FileDoesNotExistException();
    }

    if (p.extension(file.path) != '.castboard') {
      throw InvalidFileFormatException();
    }

    // Delete existing Temp Storage.
    await clearStorage();

    final bytes = await file.readAsBytes();
    final unzipper = ZipDecoder();
    final archive = unzipper.decodeBytes(bytes);

    Map<String, dynamic> rawManifest = {};
    Map<String, dynamic> rawShowData = {};
    Map<String, dynamic> rawSlideData = {};
    final fileWriteRequests = <Future<File>>[];

    for (var entity in archive) {
      final name = entity.name;
      final parentDirectoryName =
          p.split(name).isNotEmpty ? p.split(name).first : '';

      if (entity.isFile) {
        final bytedata = entity.content as List<int>;
        if (parentDirectoryName == _headshotsTempDirName) {
          fileWriteRequests.add(
              File(p.join(_headshotsDir.path, p.basename(name)))
                  .writeAsBytes(bytedata));
        }

        if (parentDirectoryName == _backgroundsTempDirName) {
          fileWriteRequests.add(
              File(p.join(_backgroundsDir.path, p.basename(name)))
                  .writeAsBytes(bytedata));
        }

        if (name == _manifestSaveName) {
          rawManifest = json.decode(utf8.decode(bytedata));
        }

        if (name == _showDataSaveName) {
          rawShowData = json.decode(utf8.decode(bytedata));
        }

        if (name == _slideDataSaveName) {
          rawSlideData = json.decode(utf8.decode(bytedata));
        }
      }
    }

    final Map<String, dynamic> rawPresets = rawShowData['presets'] ?? const {};
    final Map<String, dynamic> rawActors = rawShowData['actors'] ?? const {};
    final Map<String, dynamic> rawRoles = rawShowData['roles'] ?? const {};

    await Future.wait(fileWriteRequests);

    // TODO: Verification and Coercion.
    // -> Coerce a default Preset into existence if not already existing.
    return ImportedShowData(
        manifest: ManifestModel.fromMap(rawManifest),
        slides: Map<String, SlideModel>.fromEntries(rawSlideData.entries.map(
            (entry) => MapEntry(entry.key, SlideModel.fromMap(entry.value)))),
        actors: Map<String, ActorModel>.fromEntries(rawActors.entries.map(
            (entry) => MapEntry(entry.key, ActorModel.fromMap(entry.value)))),
        roles: Map<String, RoleModel>.fromEntries(rawRoles.entries.map(
            (entry) => MapEntry(entry.key, RoleModel.fromMap(entry.value)))),
        presets: Map<String, PresetModel>.fromEntries(rawPresets.entries.map(
            (entry) => MapEntry(entry.key, PresetModel.fromMap(entry.value)))));
  }

  Future<void> clearStorage() async {
    final headshots = <FileSystemEntity>[];
    final backgrounds = <FileSystemEntity>[];

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
    ]);

    final headshotDeleteRequests = headshots.map((file) => file.delete());
    final backgroundDeleteRequests = backgrounds.map((file) => file.delete());

    await Future.wait([...headshotDeleteRequests, ...backgroundDeleteRequests]);
    return;
  }

  Future<void> writeToPermanentStorage(
      {@required Map<String, ActorModel> actors,
      @required Map<String, SlideModel> slides,
      @required Map<String, RoleModel> roles,
      @required Map<String, PresetModel> presets,
      @required ManifestModel manifest,
      @required File targetFile}) async {
    final mfs = memoryFs.MemoryFileSystem();

    // Stage Directories in Memory.
    await _stagePermStorageDirectories(mfs);
    await Future.wait([
      _stageManifest(mfs, manifest),
      _stageHeadshots(mfs, actors),
      _stageBackgrounds(mfs, slides),
      _stageSlideData(mfs, slides),
      _stageShowData(mfs, roles, actors, presets),
    ]);

    final zipper = ZipFileEncoder();
    zipper.create(targetFile.path);
    zipper.addDirectory(mfs.directory(_headshotsSaveDirName));
    zipper.addDirectory(mfs.directory(_backgroundsSaveDirName));
    zipper.addFile(mfs.file(_manifestSaveName));
    zipper.addFile(mfs.file(_showDataSaveName));
    zipper.addFile(mfs.file(_slideDataSaveName));
    zipper.close();

    return;
  }

  Future<void> _stageManifest(
    memoryFs.MemoryFileSystem mfs,
    ManifestModel manifest,
  ) async {
    final data = manifest.toMap();

    final jsonData = json.encoder.convert(data);
    final targetFile = await mfs.file(_manifestSaveName).create();
    await targetFile.writeAsString(jsonData);
    return;
  }

  Future<void> _stageShowData(
      memoryFs.MemoryFileSystem mfs,
      Map<String, RoleModel> roles,
      Map<String, ActorModel> actors,
      Map<String, PresetModel> presets) async {
    final data = <String, dynamic>{
      'roles': Map<String, dynamic>.fromEntries(
          roles.values.map((role) => MapEntry(role.uid, role.toMap()))),
      'actors': Map<String, dynamic>.fromEntries(
          actors.values.map((actor) => MapEntry(actor.uid, actor.toMap()))),
      'presets': Map<String, dynamic>.fromEntries(
          presets.values.map((preset) => MapEntry(preset.uid, preset.toMap())))
    };

    final jsonData = json.encoder.convert(data);
    final targetFile = await mfs.file(_showDataSaveName).create();
    await targetFile.writeAsString(jsonData);
    return;
  }

  Future<void> _stageSlideData(
      memoryFs.MemoryFileSystem mfs, Map<String, SlideModel> slides) async {
    final data = Map<String, dynamic>.fromEntries(
        slides.values.map((slide) => MapEntry(slide.uid, slide.toMap())));

    final jsonData = json.encoder.convert(data);

    final targetFile = await mfs.file(_slideDataSaveName).create();

    await targetFile.writeAsString(jsonData);
    return;
  }

  Future<void> _stageBackgrounds(
      memoryFs.MemoryFileSystem mfs, Map<String, SlideModel> slides) async {
    final refs = slides.values
        .map((slide) => slide.backgroundRef)
        .where((ref) => ref != PhotoRef.none());

    final requests = refs.map((ref) {
      final sourceFile = getBackgroundFile(ref);
      return _copyToMemoryFileSystem(sourceFile,
          mfs.file(mfs.path.join(_backgroundsSaveDirName, ref.basename)));
    });

    return Future.wait(requests);
  }

  Future<void> _stageHeadshots(
      memoryFs.MemoryFileSystem mfs, Map<String, ActorModel> actors) async {
    final refs = actors.values
        .map((actor) => actor.headshotRef)
        .where((ref) => ref != PhotoRef.none());

    final requests = refs.map((ref) {
      final sourceFile = getHeadshotFile(ref);
      return _copyToMemoryFileSystem(sourceFile,
          mfs.file(mfs.path.join(_headshotsSaveDirName, ref.basename)));
    });

    return Future.wait(requests);
  }

  Future<void> _stagePermStorageDirectories(
      memoryFs.MemoryFileSystem mfs) async {
    final requests = [
      mfs.directory(_headshotsSaveDirName).create(),
      mfs.directory(_backgroundsSaveDirName).create(),
    ];
    return Future.wait(requests);
  }

  Future<File> _copyToMemoryFileSystem(File sourceFile, File targetFile) async {
    await targetFile.create(recursive: true);
    final sourceFileBytes = await sourceFile.readAsBytes();
    return await targetFile.writeAsBytes(sourceFileBytes);
  }
}
