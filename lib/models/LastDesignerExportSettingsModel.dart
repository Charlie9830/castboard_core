import 'dart:convert';

import 'package:castboard_core/enum-converters/imageInterpolationTypeConverters.dart';
import 'package:castboard_core/image_compressor/image_compressor.dart';

class LastDesignerExportSettingsModel {
  final String exportDirectory;
  final int compressionRatio;
  final bool overwriteExisting;
  final ImageInterpolationType interpolationType;

  LastDesignerExportSettingsModel({
    required this.compressionRatio,
    required this.exportDirectory,
    required this.overwriteExisting,
    required this.interpolationType,
  });

  const LastDesignerExportSettingsModel.defaults()
      : exportDirectory = '',
        compressionRatio = 90,
        overwriteExisting = true,
        interpolationType = ImageInterpolationType.average;

  LastDesignerExportSettingsModel copyWith({
    String? exportDirectory,
    int? compressionRatio,
    bool? overwriteExisting,
    ImageInterpolationType? interpolationType,
  }) {
    return LastDesignerExportSettingsModel(
      exportDirectory: exportDirectory ?? this.exportDirectory,
      compressionRatio: compressionRatio ?? this.compressionRatio,
      overwriteExisting: overwriteExisting ?? this.overwriteExisting,
      interpolationType: interpolationType ?? this.interpolationType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exportDirectory': exportDirectory,
      'compressionRatio': compressionRatio,
      'overwriteExisting': overwriteExisting,
      'interpolationType': convertImageInterpolationType(interpolationType),
    };
  }

  factory LastDesignerExportSettingsModel.fromMap(Map<String, dynamic> map) {
    return LastDesignerExportSettingsModel(
        exportDirectory: map['exportDirectory'] ?? '',
        compressionRatio: map['compressionRatio']?.toInt() ?? 0,
        overwriteExisting: map['overwriteExisting'] ?? false,
        interpolationType:
            parseImageInterpolationType(map['interpolationType']));
  }

  String toJson() => json.encode(toMap());

  factory LastDesignerExportSettingsModel.fromJson(String source) =>
      LastDesignerExportSettingsModel.fromMap(json.decode(source));
}
