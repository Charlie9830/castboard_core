import 'dart:convert';

import 'package:quiver/core.dart';

class FontRef {
  final String uid;
  final String ext;

  FontRef(this.uid, this.ext);

  const FontRef.none()
      : uid = '',
        ext = '';

  String get basename => '$uid$ext';

  @override
  int get hashCode => hash2(uid.hashCode, ext.hashCode);

  @override
  bool operator ==(Object other) {
    if (other is FontRef) {
      return uid == other.uid && ext == other.ext;
    }
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'ext': ext,
    };
  }

  factory FontRef.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const FontRef.none();
    }
    
    return FontRef(
      map['uid'],
      map['ext'],
    );
  }

  String toJson() => json.encode(toMap());

  factory FontRef.fromJson(String source) =>
      FontRef.fromMap(json.decode(source));
}
