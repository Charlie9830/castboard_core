import 'dart:typed_data';

class ImageSourceData {
  final int width;
  final int height;
  final Uint8List bytes;
  final String? tag;

  ImageSourceData({
    required this.width,
    required this.height,
    required this.bytes,
    this.tag,
  });
}