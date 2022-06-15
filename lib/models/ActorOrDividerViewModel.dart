import 'package:castboard_core/models/ActorIndex.dart';
import 'package:castboard_core/models/ActorModel.dart';

enum ActorOrDividerViewModelType {
  actor,
  divider,
}

class ActorOrDividerViewModel {
  final ActorOrDividerViewModelType type;
  final ActorIndex? actorIndex;
  final ActorModel? actorModel;
  final ActorIndexDivider? divider;

  ActorOrDividerViewModel({
    required this.type,
    this.actorIndex,
    this.actorModel,
    this.divider,
  });
}
