import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool isMobileLayout(BuildContext context) {
  final targetPlatform = Theme.of(context).platform;

  if (targetPlatform == TargetPlatform.iOS ||
      targetPlatform == TargetPlatform.android) {
    return true;
  }

  if (kDebugMode &&
      (targetPlatform == TargetPlatform.windows ||
          targetPlatform == TargetPlatform.macOS)) {
    // We are debugging with a Native build. So just return a value based on the screen size, ie ignore kIsWeb.
    return !_isLargeLayout(context);
  }

  if (kIsWeb && (_isLargeLayout(context) == false)) {
    return true;
  }

  return false;
}

bool isNotMobileLayout(BuildContext context) {
  return !isMobileLayout(context);
}

bool _isLargeLayout(BuildContext context) {
  return MediaQuery.of(context).size.width > 1200;
}
