import 'package:castboard_core/models/system_controller/AvailableResolutions.dart';
import 'package:castboard_core/models/system_controller/DeviceOrientation.dart';
import 'package:castboard_core/models/system_controller/DeviceResolution.dart';

/// Represents a device Agnostic Configuration. It is the responsibility of the Platform Implementations to pick this apart and marshall the commands to the correct
/// locations/actions.
class SystemConfig {
  final DeviceOrientation? deviceOrientation;
  final DeviceResolution? deviceResolution;
  final bool? playShowOnIdle;
  final AvailableResolutions
      availableResolutions; // Nominally only one way Player -> Remote.

  SystemConfig({
    required this.deviceOrientation,
    required this.deviceResolution,
    required this.availableResolutions,
    required this.playShowOnIdle,
  });

  SystemConfig.defaults()
      : deviceResolution = DeviceResolution.auto(),
        deviceOrientation = DeviceOrientation.landscape,
        availableResolutions = AvailableResolutions.defaults(),
        playShowOnIdle = true;

  Map<String, dynamic> toMap() {
    return {
      'deviceOrientation': deviceOrientation == null
          ? null
          : _convertOrientation(deviceOrientation!),
      'deviceResolution': deviceResolution?.toMap(),
      'availableResolutions': availableResolutions.toMap(),
      'playShowOnIdle': playShowOnIdle,
    };
  }

  factory SystemConfig.fromMap(Map<String, dynamic> map) {
    return SystemConfig(
      deviceOrientation: _parseOrientation(map['deviceOrientation']),
      deviceResolution: DeviceResolution.fromMap(map['deviceResolution']),
      availableResolutions:
          AvailableResolutions.fromMap(map['availableResolutions']),
      playShowOnIdle: map['playShowOnIdle'],
    );
  }

  SystemConfig copyWith({
    DeviceOrientation? deviceOrientation,
    DeviceResolution? deviceResolution,
    AvailableResolutions? availableResolutions,
    bool? playShowOnIdle,
  }) {
    return SystemConfig(
      deviceOrientation: deviceOrientation ?? this.deviceOrientation,
      deviceResolution: deviceResolution ?? this.deviceResolution,
      availableResolutions: availableResolutions ?? this.availableResolutions,
      playShowOnIdle: playShowOnIdle this.playShowOnIdle,
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
