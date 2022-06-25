import 'dart:convert';

import 'package:quiver/core.dart';

// TODO: Refactor the file name to ImageRef.

// TODO: Explore making uid and ext non nullable.

class ImageRef {
  final String? uid;
  final String? ext;

  ImageRef(this.uid, this.ext);

  const ImageRef.none()
      : uid = '',
        ext = '';

  String get basename => '$uid$ext';

  @override
  int get hashCode => hash2(uid.hashCode, ext.hashCode);

  @override
  bool operator ==(Object other) {
    if (other is ImageRef) {
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

  factory ImageRef.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ImageRef.none();

    return ImageRef(
      map['uid'],
      map['ext'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ImageRef.fromJson(String source) =>
      ImageRef.fromMap(json.decode(source));
}
