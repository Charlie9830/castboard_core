import 'dart:convert';

import 'package:quiver/core.dart';
import 'package:path/path.dart' as p;

class ImageRef {
  final String uid;
  final String ext;

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

  factory ImageRef.fromFilename(String fileName) {
    if (fileName.contains('.') == false) {
      return const ImageRef.none();
    }

    return ImageRef(
      p.basenameWithoutExtension(fileName),
      p.extension(fileName),
    );
  }

  String toJson() => json.encode(toMap());

  factory ImageRef.fromJson(String source) =>
      ImageRef.fromMap(json.decode(source));
}
