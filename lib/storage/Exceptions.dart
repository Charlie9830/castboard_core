class FileDoesNotExistException implements Exception {
  final String message = "File does not exist";

  FileDoesNotExistException();
}

class InvalidFileFormatException implements Exception {
  final String message = "Invalid File";

  InvalidFileFormatException();
}