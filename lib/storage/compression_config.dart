class CompressionConfig {
  // Headshots
  final maxHeadshotHeight = 1080;
  final headshotCompressionRatio = 75;

  // Images
  final maxImageHeight = 1080;
  final maxImageWidth = 1920;
  final imageCompressionRatio = 75;

  // Backgrounds
  final maxBackgroundHeight = 1080 * 4;
  final maxBackgroundWidth = 1920 * 4;
  final backgroundCompressionRatio = 75;

  static CompressionConfig get instance => CompressionConfig();
}
