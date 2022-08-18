class DecodeResult {
  final bool success;
  final int width;
  final int height;
  final List<int> bytes;

  DecodeResult({
    required this.success,
    required this.width,
    required this.height,
    required this.bytes,
  });
}
