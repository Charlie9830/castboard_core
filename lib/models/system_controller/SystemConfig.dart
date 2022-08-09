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
  final String playerVersion;
  final String playerBuildNumber;
  final String playerBuildSignature;
  final String? deviceName;
  final String versionCodename;

  SystemConfig({
    required this.deviceOrientation,
    required this.deviceResolution,
    required this.availableResolutions,
    required this.playShowOnIdle,
    required this.playerBuildNumber,
    required this.playerBuildSignature,
    required this.playerVersion,
    required this.deviceName,
    required this.versionCodename,
  });

  SystemConfig.defaults()
      : deviceResolution = const DeviceResolution.auto(),
        deviceOrientation = DeviceOrientation.landscape,
        availableResolutions = const AvailableResolutions.defaults(),
        playShowOnIdle = true,
        playerVersion = '',
        playerBuildSignature = '',
        playerBuildNumber = '',
        deviceName = 'Performer',
        versionCodename = '';

  Map<String, dynamic> toMap() {
    return {
      'deviceOrientation': deviceOrientation == null
          ? null
          : _convertOrientation(deviceOrientation!),
      'deviceResolution': deviceResolution?.toMap(),
      'availableResolutions': availableResolutions.toMap(),
      'playShowOnIdle': playShowOnIdle,
      'playerVersion': playerVersion,
      'playerBuildNumber': playerBuildNumber,
      'playerBuildSignature': playerBuildSignature,
      'deviceName': deviceName,
      'versionCodename': versionCodename,
    };
  }

  factory SystemConfig.fromMap(Map<String, dynamic> map) {
    return SystemConfig(
        deviceOrientation: _parseOrientation(map['deviceOrientation']),
        deviceResolution: DeviceResolution.fromMap(map['deviceResolution']),
        deviceName: map['deviceName'] ?? SystemConfig.defaults().deviceName,
        availableResolutions:
            AvailableResolutions.fromMap(map['availableResolutions']),
        playShowOnIdle: map['playShowOnIdle'],
        playerBuildNumber: map['playerBuildNumber'] ?? '',
        playerVersion: map['playerVersion'] ?? '',
        playerBuildSignature: map['playerBuildSignature'] ?? '',
        versionCodename: map['versionCodename'] ?? '');
  }

  SystemConfig copyWith({
    DeviceOrientation? deviceOrientation,
    DeviceResolution? deviceResolution,
    AvailableResolutions? availableResolutions,
    String? playerVersion,
    String? playerBuildNumber,
    String? playerBuildSignature,
    bool? playShowOnIdle,
    String? deviceName,
    String? versionCodename,
  }) {
    return SystemConfig(
      deviceOrientation: deviceOrientation ?? this.deviceOrientation,
      deviceResolution: deviceResolution ?? this.deviceResolution,
      availableResolutions: availableResolutions ?? this.availableResolutions,
      playShowOnIdle: playShowOnIdle ?? this.playShowOnIdle,
      playerVersion: playerVersion ?? this.playerBuildNumber,
      playerBuildNumber: playerBuildNumber ?? this.playerBuildNumber,
      playerBuildSignature: playerBuildSignature ?? this.playerBuildSignature,
      deviceName: deviceName ?? this.deviceName,
      versionCodename: versionCodename ?? this.versionCodename,
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
