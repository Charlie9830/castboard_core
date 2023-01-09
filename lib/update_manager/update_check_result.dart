enum UpdateStatus {
  upToDate,
  readyToDownload,
  readyToInstall,
  unknown,
}

class UpdateCheckResult {
  final UpdateStatus status;

  UpdateCheckResult({
    required this.status,
  });
}
