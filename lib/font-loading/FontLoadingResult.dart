

import 'package:flutter/services.dart';

class FontLoadingResult {
  final bool success;
  final String errorMessage;

  FontLoadingResult({
    this.success = false,
    this.errorMessage = 'No error message provided',
  });
}
