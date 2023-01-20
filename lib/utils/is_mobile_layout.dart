import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool isMobileLayout(BuildContext context) {
  if (Theme.of(context).platform == TargetPlatform.iOS ||
      Theme.of(context).platform == TargetPlatform.android) {
    return true;
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
