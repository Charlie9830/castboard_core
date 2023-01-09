import 'dart:convert';

import 'package:path/path.dart' as p;

class UpdateManifestModel {
  final String platform;
  final String version;
  final DateTime releaseDate;
  final String checksum;
  final String downloadPath;
  final int downloadSize;

  UpdateManifestModel({
    required this.platform,
    required this.version,
    required this.releaseDate,
    required this.checksum,
    required this.downloadPath,
    required this.downloadSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'version': version,
      'releaseDate': releaseDate.toIso8601String(),
      'checksum': checksum,
      'downloadPath': downloadPath,
      'downloadSize': downloadSize,
    };
  }

  factory UpdateManifestModel.fromMap(Map<String, dynamic> map) {
    return UpdateManifestModel(
      platform: map['platform'] ?? '',
      version: map['version'] ?? '',
      releaseDate: DateTime.parse(map['releaseDate']),
      checksum: map['checksum'] ?? '',
      downloadPath: map['downloadPath'] ?? '',
      downloadSize: map['downloadSize'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UpdateManifestModel.fromJson(String source) =>
      UpdateManifestModel.fromMap(json.decode(source));

  Uri getDownloadUrl(String serverAddress) {
    return Uri.parse('$serverAddress/${p.basename(downloadPath)}');
  }
}
