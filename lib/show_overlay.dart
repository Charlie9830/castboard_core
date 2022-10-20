import 'package:flutter/material.dart';

Future<void> showOverlay(
    {required BuildContext context,
    required Widget Function(BuildContext) builder}) async {
  showDialog(
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      context: context,
      builder: builder);
}
