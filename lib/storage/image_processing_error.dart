
class ImageProcessingError extends Error {
  final String message;

  ImageProcessingError(this.message);

  @override
  String toString() {
    return message;
  }
}
