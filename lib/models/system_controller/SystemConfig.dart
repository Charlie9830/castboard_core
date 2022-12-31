/// Represents a device Agnostic Configuration. It is the responsibility of the Platform Implementations to pick this apart and marshall the commands to the correct
/// locations/actions.
class SystemConfig {
  final bool? playShowOnIdle;
  final String playerVersion;
  final String playerBuildNumber;
  final String playerBuildSignature;
  final String versionCodename;

  SystemConfig({
    required this.playShowOnIdle,
    required this.playerBuildNumber,
    required this.playerBuildSignature,
    required this.playerVersion,
    required this.versionCodename,
  });

  SystemConfig.defaults()
      : playShowOnIdle = true,
        playerVersion = '',
        playerBuildSignature = '',
        playerBuildNumber = '',
        versionCodename = '';

  Map<String, dynamic> toMap() {
    return {
      'playShowOnIdle': playShowOnIdle,
      'playerVersion': playerVersion,
      'playerBuildNumber': playerBuildNumber,
      'playerBuildSignature': playerBuildSignature,
      'versionCodename': versionCodename,
    };
  }

  factory SystemConfig.fromMap(Map<String, dynamic> map) {
    return SystemConfig(
        playShowOnIdle: map['playShowOnIdle'],
        playerBuildNumber: map['playerBuildNumber'] ?? '',
        playerVersion: map['playerVersion'] ?? '',
        playerBuildSignature: map['playerBuildSignature'] ?? '',
        versionCodename: map['versionCodename'] ?? '');
  }

  SystemConfig copyWith({
    String? playerVersion,
    String? playerBuildNumber,
    String? playerBuildSignature,
    bool? playShowOnIdle,
    String? versionCodename,
  }) {
    return SystemConfig(
      playShowOnIdle: playShowOnIdle ?? this.playShowOnIdle,
      playerVersion: playerVersion ?? this.playerBuildNumber,
      playerBuildNumber: playerBuildNumber ?? this.playerBuildNumber,
      playerBuildSignature: playerBuildSignature ?? this.playerBuildSignature,
      versionCodename: versionCodename ?? this.versionCodename,
    );
  }
}
