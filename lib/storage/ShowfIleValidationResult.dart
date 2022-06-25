import 'package:castboard_core/models/ManifestModel.dart';

class ShowfileValidationResult {
  final bool isValid;
  final bool isCompatiableFileVersion;
  final ManifestModel? manifest;

  ShowfileValidationResult(
    this.isValid,
    this.isCompatiableFileVersion, {
    this.manifest,
  });

  ShowfileValidationResult.good(this.manifest)
      : isValid = true,
        isCompatiableFileVersion = true;
}
