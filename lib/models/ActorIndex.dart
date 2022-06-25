import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorOrDividerViewModel.dart';
import 'package:castboard_core/models/ActorRef.dart';

/// [ActorIndexBase] provides the base class for which [ActorIndex] and [ActorIndexDivider] derive from.
/// [ActorIndex] and [ActorIndexDivider] are stored in state as a List and represent the position of each
/// Actor Model and Divider within the collection of Actors. This allows for custom sort orders of Actors and
/// the associated Dividers.

const String _actorType = 'actor';
const String _dividerType = 'divider';

abstract class ActorIndexBase {
  final String type;

  ActorIndexBase(this.type);

  factory ActorIndexBase.fromMap(Map<String, dynamic> map) {
    final String type = map['type'];

    if (type == _actorType) {
      return ActorIndex.fromMap(map);
    } else {
      return ActorIndexDivider.fromMap(map);
    }
  }

  Map<String, dynamic> toMap();

  static List<ActorOrDividerViewModel> toViewModels(
      Map<ActorRef, ActorModel> actors, List<ActorIndexBase> actorIndex) {
    return actorIndex.map((item) {
      if (item is ActorIndex) {
        return item.toViewModel(actors[item.ref]!);
      }

      if (item is ActorIndexDivider) {
        return item.toViewModel();
      }

      throw UnsupportedError(
          'ActorIndexBase.toViewModels is missing handling for an ActorIndexBase item of type ${item.runtimeType}.');
    }).toList();
  }
}

class ActorIndex extends ActorIndexBase {
  final ActorRef ref;

  ActorIndex(
    this.ref,
  ) : super(_actorType);

  factory ActorIndex.fromMap(Map<String, dynamic> map) {
    return ActorIndex(
      ActorRef.fromMap(map['ref']),
    );
  }

  ActorOrDividerViewModel toViewModel(ActorModel actorModel) {
    return ActorOrDividerViewModel(
        type: ActorOrDividerViewModelType.actor,
        actorIndex: this,
        actorModel: actorModel);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'ref': ref.toMap(),
    };
  }
}

class ActorIndexDivider extends ActorIndexBase {
  final String uid;
  final String title;

  ActorIndexDivider(this.uid, this.title) : super(_dividerType);

  factory ActorIndexDivider.fromMap(Map<String, dynamic> map) {
    return ActorIndexDivider(
      map['uid'] ?? '',
      map['title'] ?? '',
    );
  }

  ActorOrDividerViewModel toViewModel() {
    return ActorOrDividerViewModel(
        type: ActorOrDividerViewModelType.divider, divider: this);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'uid': uid,
      'title': title,
    };
  }

  ActorIndexDivider copyWith({
    String? uid,
    String? title,
  }) {
    return ActorIndexDivider(
      uid ?? this.uid,
      title ?? this.title,
    );
  }
}
