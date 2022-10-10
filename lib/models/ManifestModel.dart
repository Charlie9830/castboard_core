import 'package:castboard_core/models/FontModel.dart';

const kManifestModelValidationKeyValue = 'correct-horse-battery-staple';

class ManifestModel {
  final String
      validationKey; // Used by the storage validation to ensure we are validating against an actual manifest, not just
  // some other random json file.
  final String
      showId; // showId is only set when a show is saved for the first time. We will likely use it to assist
  //  with on Performer device preset mergers.
  final String fileName;
  final String created;
  final String modified;
  final String createdByVersion;
  final int fileVersion;
  final List<FontModel> requiredFonts;
  final bool isDemoShow;

  ManifestModel({
    this.validationKey = '',
    this.showId = '',
    this.fileName = '',
    this.created = '',
    this.modified = '',
    this.createdByVersion = '',
    this.fileVersion = 1,
    this.requiredFonts = const <FontModel>[],
    this.isDemoShow = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'validationKey': kManifestModelValidationKeyValue,
      'showId': showId,
      'fileName': fileName,
      'created': created,
      'modified': modified,
      'createdByVersion': createdByVersion,
      'fileVersion': fileVersion,
      'requiredFonts': requiredFonts.map((item) => item.toMap()).toList(),
    };
  }

  factory ManifestModel.fromMap(Map<String, dynamic> map) {
    return ManifestModel(
      validationKey: map['validationKey'] ?? '',
      showId: map['showId'] ?? '',
      fileName: map['fileName'] ?? '',
      created: map['created'] ?? '',
      modified: map['modified'] ?? '',
      createdByVersion: map['createdByVersion'] ?? '',
      fileVersion: map['fileVersion'] ?? '',
      requiredFonts: ((map['requiredFonts'] ?? <dynamic>[]) as List<dynamic>)
          .map((font) => FontModel.fromMap(font))
          .toList(),
    );
  }

  ManifestModel copyWith({
    String? fileName,
    String? showId,
    String? created,
    String? modified,
    String? createdByVersion,
    int? fileVersion,
    List<FontModel>? requiredFonts,
    bool? isDemoShow,
  }) {
    return ManifestModel(
      validationKey: validationKey,
      fileName: fileName ?? this.fileName,
      showId: showId ?? this.showId,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      createdByVersion: createdByVersion ?? this.createdByVersion,
      fileVersion: fileVersion ?? this.fileVersion,
      requiredFonts: requiredFonts ?? this.requiredFonts,
      isDemoShow: isDemoShow ?? this.isDemoShow,
    );
  }
}
