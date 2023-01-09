class DownloadResult {
  final bool success;
  final String? path;
  final String? errorMessage;
  final Object? error;
  final StackTrace? stacktrace;

  DownloadResult(
    this.success, {
    this.path,
    this.errorMessage,
    this.error,
    this.stacktrace,
  });
}
