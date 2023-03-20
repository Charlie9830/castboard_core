import 'dart:io';

import 'package:castboard_core/logging/LoggingManager.dart';
import 'package:castboard_core/storage/Storage.dart';
import 'package:castboard_core/update_manager/download_result.dart';
import 'package:castboard_core/update_manager/local_update_package_model.dart';
import 'package:castboard_core/update_manager/update_check_result.dart';
import 'package:castboard_core/update_manager/update_manifest_model.dart';
import 'package:castboard_core/update_manager/verify_update_file.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:version/version.dart';

const Set<String> _kPackageExtensions = {
  '.msix',
  '.pkg',
};

class UpdateManager {
  static UpdateManager? _instance;

  static UpdateManager get instance {
    if (_instance == null) {
      throw 'Ensure UpdateManagger.initialize() has been called before accessing the instance property';
    }

    return _instance!;
  }

  static Future<void> initialize(
      {required String currentVersion,
      required String updateServerAddress}) async {
    LoggingManager.instance.autoUpdate.info('Initializing Update Manager.');

    if (updateServerAddress.isEmpty ||
        Uri.tryParse(updateServerAddress) == null) {
      LoggingManager.instance.autoUpdate.severe(
          'An invalid Update server address was provided to UpdateManager. Address must be a valid Url and must not be blank.'
          '\n Provided address was: $updateServerAddress');

      throw 'An invalid Update server address was provided to UpdateManager. Address must be a valid Url and must not be blank.'
          '\n Provided address was: $updateServerAddress';
    }

    LoggingManager.instance.autoUpdate.info('Current Version: $currentVersion');
    LoggingManager.instance.autoUpdate
        .info('Update Server Address: $updateServerAddress');

    if (kDebugMode) {
      print('Update Server Address: $updateServerAddress');
    }

    _instance = UpdateManager(
        currentVersion: currentVersion,
        updateServerAddress: updateServerAddress);
  }

  final String currentVersion;
  final String updateServerAddress;

  UpdateManifestModel? lastManifest;
  String? updatePackagePath;

  UpdateManager(
      {required this.currentVersion, required this.updateServerAddress});

  void executeUpdate() async {
    if (updatePackagePath != null) {
      LoggingManager.instance.autoUpdate
          .info("Executing update, launching $updatePackagePath!");

      // Stamp the incoming Software version into the Update status file.
      await _stampStatusFile(lastManifest!.version);

      if (Platform.isWindows) {
        Process.run(updatePackagePath!, [], runInShell: true);
      }

      if (Platform.isMacOS) {
        Process.run('open', [updatePackagePath!], runInShell: true);
      }
    } else {
      LoggingManager.instance.autoUpdate
          .severe('updatePackagePath is null. executeUpdate() cannot proceed');
      throw 'updatePackagePath is null. executeUpdate() cannot proceed';
    }
  }

  // Returns True if an Update has just been performed.
  Future<bool> didJustUpdate() async {
    final statusFile = Storage.instance.getPackageUpdateStatusFile();

    if (await statusFile.exists() == false) {
      return false;
    }

    try {
      // Status file will contain the version String of the version we were updating towards.
      final versionString = (await statusFile.readAsString()).trim();

      // Convert the Status file Version string to a Version object for comparison.
      final statusVersion = Version.parse(versionString);

      // Convert the current running version string to a Version object for comparison.
      final runningVersion = Version.parse(currentVersion);

      // Compare the version objects. If they resolve as the same, then we have succesfully updated to the version recorded in the update status file.
      return statusVersion.compareTo(runningVersion) == 0;
    } catch (e) {
      LoggingManager.instance.autoUpdate
          .warning('Failed to parse version status file.');
      return false;
    }
  }

  Future<void> cleanupFiles() async {
    const Set<String> cleanupExtensions = {
      ..._kPackageExtensions,
      '.json',
    };

    final List<Future<FileSystemEntity>> deleteRequests = [];
    await for (final entity
        in Storage.instance.getPackageUpdateDirectory().list()) {
      if (entity is File &&
          cleanupExtensions.contains(p.basename(entity.path))) {
        deleteRequests.add(entity.delete());
      }
    }

    deleteRequests.add(Storage.instance.getPackageUpdateStatusFile().delete());

    await Future.wait(deleteRequests);
  }

  Future<UpdateCheckResult> checkForUpdates() async {
    // First check if we have any already downloaded packages ready to go. If we do,
    // We will keep it in our pocket as a Fallback for if we are unable to contact the
    // update server.
    final LocalUpdatePackageModel? localPackage = await _checkForLocalUpdates();
    final UpdateManifestModel? localManifest = localPackage == null
        ? null
        : await _fetchLocalUpdateManifest(localPackage.manifestFilePath);

    // Address of the Update Manifest File.
    final manifestAddress = _getManifestAddress();

    LoggingManager.instance.autoUpdate.info(
        'Checking for software updates from ${manifestAddress.toString()}');

    // Fetch the Manifest
    http.Response manifestResponse;
    try {
      manifestResponse = await http.get(manifestAddress);
    } catch (e, stacktrace) {
      // Unable to contact Update Server. Log the occurance and then attempt to update from a previously
      // downloaded update package.
      LoggingManager.instance.autoUpdate
          .info("Unable to fetch Update Manifest", e, stacktrace);

      if (localPackage != null && localManifest != null) {
        // We have a suitable local package already downloaded. It may not strictly be the most up to date. But at least its something.
        LoggingManager.instance.autoUpdate
            .info('Suitable local update package located. Using that instead');
        updatePackagePath = localPackage.path;
        lastManifest = localManifest;
        return UpdateCheckResult(status: UpdateStatus.readyToInstall);
      }

      return UpdateCheckResult(status: UpdateStatus.unknown);
    }

    // We received a reply from the Update server. Convert it to a Domain object.
    UpdateManifestModel manifest;
    try {
      manifest = UpdateManifestModel.fromJson(manifestResponse.body);
    } catch (e, stacktrace) {
      // Unable to parse the Manifest file. Log the occurance then Attempt to update off an already downloaded package
      // if we have one.
      LoggingManager.instance.autoUpdate
          .warning("Unable to parse Update Manifest", e, stacktrace);

      if (localPackage != null && localManifest != null) {
        // We have a suitable local package already downloaded. It may not strictly be the most up to date. But at least its something.
        LoggingManager.instance.autoUpdate
            .info('Suitable local update package located. Using that instead');
        updatePackagePath = localPackage.path;
        lastManifest = localManifest;
        return UpdateCheckResult(status: UpdateStatus.readyToInstall);
      }

      return UpdateCheckResult(status: UpdateStatus.unknown);
    }

    if (manifest.version == currentVersion) {
      // Running and remote version matches. No update required.
      lastManifest = manifest;
      return UpdateCheckResult(status: UpdateStatus.upToDate);
    }

    // Compare our running version to that of the manifest version.
    if (_isCurrentOutdated(currentVersion, manifest.version)) {
      // Newer version if available on the Server.
      lastManifest = manifest;
      return UpdateCheckResult(status: UpdateStatus.readyToDownload);
    }

    if (Version.parse(currentVersion) > Version.parse(manifest.version)) {
      LoggingManager.instance.autoUpdate.warning(
          'Local application package version is ahead of update server package version.');
      return UpdateCheckResult(status: UpdateStatus.unknown);
    }

    // All options exhausted. Return an unknown Status.
    return UpdateCheckResult(status: UpdateStatus.unknown);
  }

  Future<UpdateManifestModel?> _fetchLocalUpdateManifest(String path) async {
    final file = File(path);

    if (await file.exists() == false) {
      return null;
    }

    UpdateManifestModel itemManifest;
    try {
      itemManifest = UpdateManifestModel.fromJson(await file.readAsString());
    } catch (e, stacktrace) {
      LoggingManager.instance.autoUpdate
          .warning('Failed to parse local Update Item Manifest', e, stacktrace);
      return null;
    }

    return itemManifest;
  }

  /// Returns the [File] reference to the highest ranked Local update package. That is a package with the highest version number
  /// that is also higher then the current version number. Additionally it runs a checksum on the file to ensure it's integrity.
  Future<LocalUpdatePackageModel?> _checkForLocalUpdates() async {
    // Traverse the Updates directory and collect references to the packages found there.
    List<LocalUpdatePackageModel> localUpdates = [];
    await for (final entity
        in Storage.instance.getPackageUpdateDirectory().list()) {
      if (entity is File &&
          _kPackageExtensions.contains(p.extension(entity.path))) {
        localUpdates.add(LocalUpdatePackageModel.fromFilePath(entity.path));
      }
    }

    final runningVersion = Version.parse(currentVersion);

    // Prune out any results where the version number is equal to or lower then the current running version.
    localUpdates
        .removeWhere((update) => update.version.compareTo(runningVersion) <= 0);

    if (localUpdates.isEmpty) {
      // Nothing left. Bail out.
      return null;
    }

    // Sort what's left in ascending version order.
    localUpdates.sort((a, b) => a.version.compareTo(b.version));

    // We now have our package file that is guaranteed to be most up to date.
    // We will now verify it's integrity.
    final package = localUpdates.last;

    // Get the relevant Item manifest file.
    final manifestFile = File(package.manifestFilePath);

    if (await manifestFile.exists() == false) {
      // No Manifest file. Therefore we can't verify the integrity of the update package.
      return null;
    }

    UpdateManifestModel itemManifest;
    try {
      itemManifest =
          UpdateManifestModel.fromJson(await manifestFile.readAsString());
    } catch (e, stacktrace) {
      LoggingManager.instance.autoUpdate
          .warning('Failed to parse item Manifest', e, stacktrace);
      return null;
    }

    if (await _verifyChecksum(itemManifest.checksum, File(package.path)) ==
        false) {
      // Checksum invalid. File is unuseable.
      return null;
    }

    return package;
  }

  Future<DownloadResult> downloadUpdate(
      {void Function(int percent)? onProgress}) async {
    if (lastManifest == null) {
      LoggingManager.instance.autoUpdate.warning(
          "lastManifest was null. Ensure UpdateManager.checkForUpdates() has been run prior to calling UpdateManager.downloadUpdate");
      return DownloadResult(false,
          error:
              "lastManifest was null. Ensure UpdateManager.checkForUpdates() has been run prior to calling UpdateManager.downloadUpdate");
    }

    final result = await _downloadUpdatePackage(
        itemManifest: lastManifest!, onProgress: onProgress);

    updatePackagePath = result.path;

    return result;
  }

  Future<DownloadResult> _downloadUpdatePackage({
    required UpdateManifestModel itemManifest,
    void Function(int percent)? onProgress,
  }) async {
    final url =
        Uri.parse('${itemManifest.getDownloadUrl(updateServerAddress)}');
    final fileName = p.basename(itemManifest.downloadPath);
    final sizeInBytes = itemManifest.downloadSize;
    final checksum = itemManifest.checksum;

    LoggingManager.instance.autoUpdate
        .info("Downloading Update package from ${url.toString()}");
    final client = http.Client();
    final request = http.Request('GET', url);
    final responseStream = await client.send(request);

    final targetPackageFile = File(
        p.join(Storage.instance.getPackageUpdateDirectory().path, fileName));
    final fileSink = targetPackageFile.openWrite(mode: FileMode.writeOnly);

    // Stream the response bytes into the targetPackageFile.
    int downloadedBytes = 0;
    try {
      await for (var chunk in responseStream.stream) {
        fileSink.add(chunk);
        downloadedBytes += chunk.length;

        if (onProgress != null && downloadedBytes != 0 && sizeInBytes != 0) {
          onProgress.call(((downloadedBytes / sizeInBytes) * 100)
              .ceil()
              .clamp(0, 100)
              .toInt());
        }
      }
    } catch (e, stacktrace) {
      LoggingManager.instance.autoUpdate.info(
          "Error occurred whilst downloading update file.", e, stacktrace);
      return DownloadResult(
        false,
        errorMessage:
            'An Error occurred downloading the update. URL: ${url.toString()}',
        error: e,
        stacktrace: stacktrace,
      );
    } finally {
      await fileSink.flush();
      await fileSink.close();
      client.close();
    }

    // Verify the Integrity of the file.
    final integrityResult = await _verifyChecksum(checksum, targetPackageFile);

    if (integrityResult == false) {
      LoggingManager.instance.autoUpdate
          .warning('Downloaded update package failed integrity check');
      return DownloadResult(false,
          errorMessage:
              'Downloaded file failed integrity check. Please try again.');
    }

    // Write the item manifest file to disk.
    final updatePackageModel =
        LocalUpdatePackageModel.fromFilePath(targetPackageFile.path);

    // Item manifest.
    await File(updatePackageModel.manifestFilePath)
        .writeAsString(itemManifest.toJson());

    LoggingManager.instance.autoUpdate.info("Download complete");
    return DownloadResult(true, path: targetPackageFile.path);
  }

  Future<bool> _verifyChecksum(String remoteChecksum, File file) async {
    return verifyUpdateFile(VerifyUpdateFileParams(
        remoteChecksum: remoteChecksum.trim(), filePath: file.path));
  }

  Future<void> _stampStatusFile(String incomingVersion) async {
    await Storage.instance
        .getPackageUpdateStatusFile()
        .writeAsString(incomingVersion);
    return;
  }

  Uri _getManifestAddress() {
    final platformSlug = Platform.isMacOS ? 'macos' : 'windows';
    return Uri.parse('$updateServerAddress/$platformSlug.json');
  }

  bool _isCurrentOutdated(String current, String incoming) {
    final currentVersion = Version.parse(current);
    final incomingVersion = Version.parse(incoming);

    return currentVersion < incomingVersion;
  }
}
