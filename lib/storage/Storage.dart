import 'dart:io';

import 'package:castboard_core/classes/PhotoRef.dart';
import 'package:castboard_core/storage/StorageException.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const _headshots = 'headshots';
const _backgrounds = 'backgrounds';
const _slideThumbnails = 'slidethumbnails';

class Storage {
  static Storage _instance;
  static bool _initalized = false;

  final Directory _appStorageRoot;
  final Directory _headshotsDir;
  final Directory _backgroundsDir;
  final Directory _slideThumbnailsDir;

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
      Directory slideThumbnails})
      : _appStorageRoot = appStorageRoot,
        _headshotsDir = headshots,
        _backgroundsDir = backgrounds,
        _slideThumbnailsDir = slideThumbnails;

  static Future<void> initalize() async {
    if (_initalized) {
      throw StorageException(
          'Storage is already initalized. Ensure you are only calling Storage.initalize once');
    }

    final appStorageRoot = await Directory(p.join(
            (await getTemporaryDirectory()).path, 'com.charliehall.castboard'))
        .create();

    // Build Directories.
    Directory headshots;
    Directory backgrounds;
    Directory slideThumbnails;
    await Future.wait([
      () async {
        headshots =
            await Directory(p.join(appStorageRoot.path, _headshots)).create();
        return;
      }(),
      () async {
        backgrounds =
            await Directory(p.join(appStorageRoot.path, _backgrounds)).create();
        return;
      }(),
      () async {
        slideThumbnails =
            await Directory(p.join(appStorageRoot.path, _slideThumbnails))
                .create();
        return;
      }(),
    ]);

    _instance = Storage(
        appStorageRoot: appStorageRoot,
        headshots: headshots,
        backgrounds: backgrounds,
        slideThumbnails: slideThumbnails);
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

  Future<File> _searchForFile(Directory directory, String uid) async {
    if (await directory.exists()) {
      final stream = directory.list();

      await for (var entity in stream) {
        if (entity is File && p.basenameWithoutExtension(entity.path) == uid) {
          return entity;
        }
      }

      return null;
    }

    return null;
  }

  File getHeadshotFile(PhotoRef ref) {
    return File(p.join(_appStorageRoot.path, _headshots, ref.basename));
  }

  File getBackgroundFile(PhotoRef ref) {
    return File(p.join(_appStorageRoot.path, _backgrounds, ref.basename));
  }

  File getSlideThumbnailFile(String slideId) {
    return File(p.join(_appStorageRoot.path, _slideThumbnails, '$slideId.jpg'));
  }
}
