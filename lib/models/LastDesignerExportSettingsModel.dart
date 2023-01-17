import 'dart:convert';

import 'package:castboard_core/enum-converters/imageInterpolationTypeConverters.dart';
import 'package:castboard_core/image_compressor/image_compressor.dart';

class LastDesignerExportSettingsModel {
  final String exportDirectory;
  final int compressionRatio;
  final bool overwriteExisting;
  final ImageInterpolationType interpolationType;
  final Set<String> disabledSlideIds;
  final bool clearExisting;

  LastDesignerExportSettingsModel({
    required this.compressionRatio,
    required this.exportDirectory,
    required this.overwriteExisting,
    required this.interpolationType,
    required this.disabledSlideIds,
    required this.clearExisting,
  });

  const LastDesignerExportSettingsModel.defaults()
      : exportDirectory = '',
        compressionRatio = 90,
        overwriteExisting = true,
        interpolationType = ImageInterpolationType.average,
        disabledSlideIds = const <String>{},
        clearExisting = false;

  LastDesignerExportSettingsModel copyWith({
    String? exportDirectory,
    int? compressionRatio,
    bool? overwriteExisting,
    ImageInterpolationType? interpolationType,
    Set<String>? disabledSlideIds,
    bool? clearExisting,
  }) {
    return LastDesignerExportSettingsModel(
      exportDirectory: exportDirectory ?? this.exportDirectory,
      compressionRatio: compressionRatio ?? this.compressionRatio,
      overwriteExisting: overwriteExisting ?? this.overwriteExisting,
      interpolationType: interpolationType ?? this.interpolationType,
      disabledSlideIds: disabledSlideIds ?? this.disabledSlideIds,
      clearExisting: clearExisting ?? this.clearExisting,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exportDirectory': exportDirectory,
      'compressionRatio': compressionRatio,
      'overwriteExisting': overwriteExisting,
      'interpolationType': convertImageInterpolationType(interpolationType),
      'disabledSlideIds': disabledSlideIds.toList(),
      'clearExisting': clearExisting,
    };
  }

  factory LastDesignerExportSettingsModel.fromMap(Map<String, dynamic> map) {
    return LastDesignerExportSettingsModel(
      exportDirectory: map['exportDirectory'] ?? '',
      compressionRatio: map['compressionRatio']?.toInt() ?? 0,
      overwriteExisting: map['overwriteExisting'] ?? false,
      interpolationType: parseImageInterpolationType(map['interpolationType']),
      disabledSlideIds:
          ((map['disabledSlideIds'] ?? <String>[]) as List<dynamic>)
              .map((item) => item as String)
              .toSet(),
      clearExisting: map['clearExisting'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory LastDesignerExportSettingsModel.fromJson(String source) =>
      LastDesignerExportSettingsModel.fromMap(json.decode(source));
}
