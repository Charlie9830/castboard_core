class CompressionConfig {
  // Headshots
  final maxHeadshotHeight = 1080;
  final headshotCompressionRatio = 75;
  final String headshotExtension = '.jpg';

  // Images
  final maxImageHeight = 1080;
  final maxImageWidth = 1920;
  final imageCompressionRatio = 75;
  
  // Images are allowed to be jpg or png format (In order to preserve Transparency in png formatted images).
  // final String imageExtension = '.jpg';

  // Backgrounds
  final maxBackgroundHeight = 1080 * 4;
  final maxBackgroundWidth = 1920 * 4;
  final backgroundCompressionRatio = 75;
  final backgroundExtension = '.jpg';

  static CompressionConfig get instance => CompressionConfig();
}
