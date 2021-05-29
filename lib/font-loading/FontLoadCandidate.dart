

import 'dart:typed_data';

import 'package:castboard_core/font-loading/FontLoadingResult.dart';

class FontLoadCandidate {
  final String uid;
  final String familyName;
  final Uint8List data;

  FontLoadingResult? loadResult;

  FontLoadCandidate(this.uid, this.familyName, this.data);

  void setLoadResult(FontLoadingResult result) {
    loadResult = result;
  }
}
