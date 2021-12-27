import 'package:castboard_core/logging/LoggingManager.dart';
import 'package:castboard_core/models/ManifestModel.dart';

// Check that the manifest has the correct value for it's 'validationKey' property.
bool validateManifest(ManifestModel manifest) {
  if (manifest.validationKey == manifestModelValidationKeyValue) {
    return true;
  } else {
    LoggingManager.instance.storage.warning(
        'Showfile validation failed due manifest having incorrect validationKey');
    return false;
  }
}
