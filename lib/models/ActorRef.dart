class ActorRef {
  final String uid;

  ActorRef(this.uid);

  const ActorRef.blank() : uid = '';

  const ActorRef.cut() : uid = 'CUT';
  const ActorRef.unassigned() : uid = 'UNASSIGNED';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
    };
  }

  factory ActorRef.fromMap(Map<String, dynamic> map) {
    final String uid = map['uid'];

    if (uid == ActorRef.cut().uid) {
      return const ActorRef.cut();
    }

    if (uid == ActorRef.unassigned().uid) {
      return const ActorRef.unassigned();
    }

    return ActorRef(
      uid,
    );
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is ActorRef) {
      return this.uid == other.uid;
    }
    return false;
  }
}
