import 'dart:io';

class StorageException extends Error {
  final String message;

  StorageException(this.message);

  @override
  String toString() {
    return message ?? 'StorageException thrown but no message was provided';
  }
}
