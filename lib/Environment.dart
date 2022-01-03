class Environment {
  static const String eLinuxTmpPath =
      String.fromEnvironment('ELINUX_TMP_PATH', defaultValue: '/tmp/');
  static const String eLinuxHomePath =
      String.fromEnvironment('ELINUX_HOME_PATH', defaultValue: '/home/cage/');
  static const String _isElinux =
      String.fromEnvironment('ELINUX_IS_ELINUX', defaultValue: 'false');

  static bool get isElinux => _isElinux == 'true';
}
