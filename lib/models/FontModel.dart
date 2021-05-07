import 'dart:convert';

import 'package:castboard_core/enum-converters/fontEncodingConverters.dart';
import 'package:flutter/foundation.dart';

enum FontEncoding { ttf, otf }

class FontModel {
  final String uid;
  final String familyName;
  final String path;
  final FontEncoding encoding;

  FontModel({
    this.uid = '',
    this.familyName = '',
    this.path = '',
    @required this.encoding,
  });

  FontModel copyWith({
    String uid,
    String familyName,
    String path,
    FontEncoding encoding,
  }) {
    return FontModel(
      uid: uid ?? this.uid,
      familyName: familyName ?? this.familyName,
      path: path ?? this.path,
      encoding: encoding ?? this.encoding,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'familyName': familyName,
      'path': path,
      'encoding': convertFontEncoding(encoding),
    };
  }

  factory FontModel.fromMap(Map<String, dynamic> map) {
    return FontModel(
      uid: map['uid'],
      familyName: map['familyName'],
      path: map['path'],
      encoding: parseFontEncoding(map['encoding']),
    );
  }
}
