/// Represents a device Agnostic Configuration. It is the responsibility of the Platform Implementations to pick this apart and marshall the commands to the correct
/// locations/actions.
class SystemConfig {
  final bool? playShowOnIdle;
  final String playerVersion;
  final String playerBuildNumber;
  final String playerBuildSignature;
  final String versionCodename;
  final int serverPort;
  final String deviceId;
  final String deviceName;

  SystemConfig({
    required this.playShowOnIdle,
    required this.playerBuildNumber,
    required this.playerBuildSignature,
    required this.playerVersion,
    required this.versionCodename,
    required this.serverPort,
    required this.deviceId,
    required this.deviceName,
  });

  SystemConfig.defaults()
      : playShowOnIdle = true,
        playerVersion = '',
        playerBuildSignature = '',
        playerBuildNumber = '',
        versionCodename = '',
        serverPort = 0,
        deviceId = '',
        deviceName = 'Performer';

  Map<String, dynamic> toMap() {
    return {
      'playShowOnIdle': playShowOnIdle,
      'playerVersion': playerVersion,
      'playerBuildNumber': playerBuildNumber,
      'playerBuildSignature': playerBuildSignature,
      'versionCodename': versionCodename,
      'serverPort': serverPort,
      'deviceId': deviceId,
      'deviceName': deviceName,
    };
  }

  factory SystemConfig.fromMap(Map<String, dynamic> map) {
    return SystemConfig(
        playShowOnIdle: map['playShowOnIdle'],
        playerBuildNumber: map['playerBuildNumber'] ?? '',
        playerVersion: map['playerVersion'] ?? '',
        playerBuildSignature: map['playerBuildSignature'] ?? '',
        versionCodename: map['versionCodename'] ?? '',
        serverPort: map['serverPort'] ?? 0,
        deviceId: map['deviceId'] ?? '',
        deviceName: map['deviceName'] ?? '');
  }

  SystemConfig copyWith({
    String? playerVersion,
    String? playerBuildNumber,
    String? playerBuildSignature,
    bool? playShowOnIdle,
    String? versionCodename,
    int? serverPort,
    String? deviceId,
    String? deviceName,
  }) {
    return SystemConfig(
      playShowOnIdle: playShowOnIdle ?? this.playShowOnIdle,
      playerVersion: playerVersion ?? this.playerVersion,
      playerBuildNumber: playerBuildNumber ?? this.playerBuildNumber,
      playerBuildSignature: playerBuildSignature ?? this.playerBuildSignature,
      versionCodename: versionCodename ?? this.versionCodename,
      serverPort: serverPort ?? this.serverPort,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
    );
  }
}
