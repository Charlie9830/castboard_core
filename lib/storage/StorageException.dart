
class StorageException extends Error {
  final String message;

  StorageException(this.message);

  @override
  String toString() {
    return message;
  }
}
