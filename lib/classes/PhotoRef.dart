import 'package:quiver/core.dart';

class PhotoRef {
  final String uid;
  final String ext;

  PhotoRef(this.uid, this.ext);

  const PhotoRef.none()
      : uid = '',
        ext = '';

  String get basename => '$uid$ext';

  @override
  int get hashCode => hash2(uid.hashCode, ext.hashCode);

  @override
  bool operator ==(Object other) {
    if (other is PhotoRef) {
      return this.uid == other.uid && this.ext == other.ext;
    }
    return false;
  }
}
