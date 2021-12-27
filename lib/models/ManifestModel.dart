import 'package:castboard_core/models/FontModel.dart';

const manifestModelValidationKeyValue = 'correct-horse-battery-staple';

class ManifestModel {
  final String
      validationKey; // Used by the storage validation to ensure we are validating against an actual manifest, not just
  // some other random json file.
  final String fileName;
  final String created;
  final String modified;
  final String createByVersion;
  final String fileVersion;
  final List<FontModel> requiredFonts;

  ManifestModel({
    this.validationKey = '',
    this.fileName = '',
    this.created = '',
    this.modified = '',
    this.createByVersion = '',
    this.fileVersion = '',
    this.requiredFonts = const <FontModel>[],
  });

  Map<String, dynamic> toMap() {
    return {
      'validationKey': manifestModelValidationKeyValue,
      'fileName': fileName,
      'created': created,
      'modified': modified,
      'createByVersion': createByVersion,
      'fileVersion': fileVersion,
      'requiredFonts': requiredFonts.map((item) => item.toMap()).toList(),
    };
  }

  factory ManifestModel.fromMap(Map<String, dynamic> map) {
    return ManifestModel(
      validationKey: map['validationKey'] ?? '',
      fileName: map['fileName'] ?? '',
      created: map['created'] ?? '',
      modified: map['modified'] ?? '',
      createByVersion: map['createByVersion'] ?? '',
      fileVersion: map['fileVersion'] ?? '',
      requiredFonts: ((map['requiredFonts'] ?? <dynamic>[]) as List<dynamic>)
          .map((font) => FontModel.fromMap(font))
          .toList(),
    );
  }

  ManifestModel copyWith({
    String? fileName,
    String? created,
    String? modified,
    String? createByVersion,
    String? fileVersion,
    List<FontModel>? requiredFonts,
  }) {
    return ManifestModel(
      validationKey: validationKey,
      fileName: fileName ?? this.fileName,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      createByVersion: createByVersion ?? this.createByVersion,
      fileVersion: fileVersion ?? this.fileVersion,
      requiredFonts: requiredFonts ?? this.requiredFonts,
    );
  }
}
