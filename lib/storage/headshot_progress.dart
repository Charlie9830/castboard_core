class HeadshotProgress {
  final int done;
  final int total;
  final HeadshotProcessingError? error;

  HeadshotProgress(
    this.done,
    this.total, {
    this.error,
  });
}

class HeadshotProcessingError {
  final String headshotUid;
  final String path;

  HeadshotProcessingError(this.headshotUid, this.path);
}
