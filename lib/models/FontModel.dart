import 'dart:convert';

import 'package:castboard_core/classes/FontRef.dart';
import 'package:castboard_core/enum-converters/fontEncodingConverters.dart';
import 'package:flutter/foundation.dart';

enum FontEncoding { ttf, otf }

class FontModel {
  final String uid;
  final String familyName;

  final FontRef ref;
  final FontEncoding encoding;

  FontModel({
    this.uid = '',
    this.familyName = '',
    this.ref = const FontRef.none(),
    required this.encoding,
  });

  FontModel copyWith({
    String? uid,
    String? familyName,
    String? path,
    FontEncoding? encoding,
  }) {
    return FontModel(
      uid: uid ?? this.uid,
      familyName: familyName ?? this.familyName,
      ref: path as FontRef? ?? this.ref,
      encoding: encoding ?? this.encoding,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'familyName': familyName,
      'ref': ref.toMap(),
      'encoding': convertFontEncoding(encoding),
    };
  }

  factory FontModel.fromMap(Map<String, dynamic> map) {
    return FontModel(
      uid: map['uid'] ?? '',
      familyName: map['familyName'] ?? '',
      ref: FontRef.fromMap(map['ref']),
      encoding: parseFontEncoding(map['encoding']),
    );
  }
}
