const _blankUid = '';
const _cutUid = 'CUT';
const _unassignedUid = 'UNASSIGNED';

class ActorRef {
  final String uid;

  ActorRef(this.uid);

  const ActorRef.blank() : uid = _blankUid;
  const ActorRef.cut() : uid = _cutUid;
  const ActorRef.unassigned() : uid = _unassignedUid;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
    };
  }

  String toJsonKey() {
    return uid;
  }

  factory ActorRef.fromJsonKey(String? key) {
    if (key == null) {
      return const ActorRef.blank();
    }

    final String uid = key;

    if (uid == const ActorRef.cut().uid) {
      return const ActorRef.cut();
    }

    if (uid == const ActorRef.unassigned().uid) {
      return const ActorRef.unassigned();
    }

    return ActorRef(
      uid,
    );
  }

  factory ActorRef.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const ActorRef.blank();
    }
    
    final String uid = map['uid'] ?? _blankUid;

    if (uid == const ActorRef.cut().uid) {
      return const ActorRef.cut();
    }

    if (uid == const ActorRef.unassigned().uid) {
      return const ActorRef.unassigned();
    }

    return ActorRef(
      uid,
    );
  }

  bool get isBlank => uid == _blankUid;
  bool get isCut => uid == _cutUid;
  bool get isUnassigned => uid == _unassignedUid;

  @override
  int get hashCode => uid.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is ActorRef) {
      return uid == other.uid;
    }
    return false;
  }
}
