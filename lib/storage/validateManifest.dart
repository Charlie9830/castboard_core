import 'package:castboard_core/models/ManifestModel.dart';

// Check that the manifest has the correct value for it's 'validationKey' property.
bool validateManifest(ManifestModel manifest) {
  return manifest.validationKey == manifestModelValidationKeyValue;
}
