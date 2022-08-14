import 'dart:convert';

class LastDesignerExportSettingsModel {
  final String exportDirectory;
  final int compressionRatio;
  final bool overwriteExisting;

  LastDesignerExportSettingsModel({
    required this.compressionRatio,
    required this.exportDirectory,
    required this.overwriteExisting,
  });

  const LastDesignerExportSettingsModel.defaults()
      : exportDirectory = '',
        compressionRatio = 90,
        overwriteExisting = true;

  LastDesignerExportSettingsModel copyWith({
    String? exportDirectory,
    int? compressionRatio,
    bool? overwriteExisting,
  }) {
    return LastDesignerExportSettingsModel(
      exportDirectory: exportDirectory ?? this.exportDirectory,
      compressionRatio: compressionRatio ?? this.compressionRatio,
      overwriteExisting: overwriteExisting ?? this.overwriteExisting,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exportDirectory': exportDirectory,
      'compressionRatio': compressionRatio,
      'overwriteExisting': overwriteExisting,
    };
  }

  factory LastDesignerExportSettingsModel.fromMap(Map<String, dynamic> map) {
    return LastDesignerExportSettingsModel(
      exportDirectory: map['exportDirectory'] ?? '',
      compressionRatio: map['compressionRatio']?.toInt() ?? 0,
      overwriteExisting: map['overwriteExisting'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory LastDesignerExportSettingsModel.fromJson(String source) =>
      LastDesignerExportSettingsModel.fromMap(json.decode(source));
}
