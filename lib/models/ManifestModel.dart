class ManifestModel {
  final String fileName;
  final String created;
  final String modifed;
  final String createByVersion;
  final String fileVersion;

  ManifestModel({
    this.fileName = '',
    this.created = '',
    this.modifed = '',
    this.createByVersion = '',
    this.fileVersion = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'created': created,
      'modifed': modifed,
      'createByVersion': createByVersion,
      'fileVersion': fileVersion,
    };
  }

  factory ManifestModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ManifestModel(
      fileName: map['fileName'],
      created: map['created'],
      modifed: map['modifed'],
      createByVersion: map['createByVersion'],
      fileVersion: map['fileVersion'],
    );
  }

  ManifestModel copyWith({
    String fileName,
    String created,
    String modifed,
    String createByVersion,
    String fileVersion,
  }) {
    return ManifestModel(
      fileName: fileName ?? this.fileName,
      created: created ?? this.created,
      modifed: modifed ?? this.modifed,
      createByVersion: createByVersion ?? this.createByVersion,
      fileVersion: fileVersion ?? this.fileVersion,
    );
  }
}
