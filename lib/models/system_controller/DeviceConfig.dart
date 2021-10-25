import 'package:castboard_core/models/system_controller/DeviceOrientation.dart';
import 'package:castboard_core/models/system_controller/DeviceResolution.dart';

/// Represents a device Agnostic Configuration. It is the responsability of the Platform Implementations to pick this apart and marshall the commands to the correct
/// locations/actions.
class DeviceConfig {
  final DeviceOrientation? deviceOrientation;
  final DeviceResolution? deviceResolution;

  DeviceConfig({
    required this.deviceOrientation,
    required this.deviceResolution,
  });

  DeviceConfig.defaults()
      : deviceResolution = DeviceResolution.defaults(),
        deviceOrientation = DeviceOrientation.landscape;

  Map<String, dynamic> toMap() {
    return {
      'deviceOrientation': deviceOrientation == null
          ? null
          : _convertOrientation(deviceOrientation!),
      'deviceResolution': deviceResolution?.toMap(),
    };
  }

  factory DeviceConfig.fromMap(Map<String, dynamic> map) {
    return DeviceConfig(
      deviceOrientation: _parseOrientation(map['deviceOrientation']),
      deviceResolution: DeviceResolution.fromMap(map['deviceResolution']),
    );
  }
}

DeviceOrientation _parseOrientation(String value) {
  switch (value) {
    case 'landscape':
      return DeviceOrientation.landscape;
    case 'portraitLeft':
      return DeviceOrientation.portraitLeft;
    case 'portraitRight':
      return DeviceOrientation.portraitRight;
    default:
      return DeviceOrientation.landscape;
  }
}

String _convertOrientation(DeviceOrientation ori) {
  switch (ori) {
    case DeviceOrientation.landscape:
      return 'landscape';
    case DeviceOrientation.portraitLeft:
      return 'portraitLeft';
    case DeviceOrientation.portraitRight:
      return 'portraitRight';
  }
}
