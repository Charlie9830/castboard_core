class TrackRef {
  final String uid;

  TrackRef(this.uid);

  const TrackRef.blank() : uid = '';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
    };
  }

  factory TrackRef.fromMap(Map<String, dynamic> map) {
    return TrackRef(
      map['uid'],
    );
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is TrackRef) {
      return this.uid == other.uid;
    }
    return false;
  }
}