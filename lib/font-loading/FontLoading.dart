

import 'dart:typed_data';

import 'package:castboard_core/font-loading/FontLoadCandidate.dart';
import 'package:castboard_core/font-loading/FontLoadingError.dart';
import 'package:castboard_core/font-loading/FontLoadingResult.dart';
import 'package:flutter/services.dart';

class FontLoading {
  static Future<FontLoadingResult> loadFont(
      String familyName, Uint8List data) async {
    if (familyName.isEmpty) {
      throw FontLoadingError(
          'No familyName was provided to loadFont. A family name is required');
    }

    final loaderDelegate = () async {
      return ByteData.sublistView(data);
    };

    final loader = FontLoader(familyName);
    loader.addFont(loaderDelegate());

    try {
      await loader.load();
    } catch (error) {
      return FontLoadingResult(
          success: false, errorMessage: 'An error occured.');
    }

    return FontLoadingResult(success: true);
  }

  ///
  /// Loads the provided collection of FontLoadCandidates into the Flutter Engine. Will return a list of FontLoadCandidates
  /// with their loadResult set to the outcome of each of their loads.
  ///
  static Future<List<FontLoadCandidate>> loadFonts(
      Iterable<FontLoadCandidate> candidates) async {
    if (candidates.isEmpty) {
      return <FontLoadCandidate>[];
    }

    final _candidates = candidates.toList();

    final loadRequests = _candidates.map((item) =>
        loadFont(item.familyName, item.data)
          ..then((result) => item.setLoadResult(result)));

    await Future.wait(loadRequests);

    return _candidates;
  }
}
