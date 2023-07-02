import 'package:castboard_core/elements/HeadshotElementModel.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/CastChangeModel.dart';

ActorModel? getAssignedActor(HeadshotElementModel element,
    CastChangeModel? castChange, Map<ActorRef, ActorModel>? actors) {
  if (castChange == null) {
    return null;
  }

  final actorRef = castChange.actorAt(element.trackRef);

  if (actorRef == null ||
      actorRef.isBlank ||
      actors!.containsKey(actorRef) == false) {
    return null;
  }

  return actors[actorRef];
}
