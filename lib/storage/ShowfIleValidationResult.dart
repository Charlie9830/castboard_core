class ShowfileValidationResult {
  final bool isValid;
  final bool isCompatiableFileVersion;

  ShowfileValidationResult(this.isValid, this.isCompatiableFileVersion);

  ShowfileValidationResult.good()
      : isValid = true,
        isCompatiableFileVersion = true;
}
