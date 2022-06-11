import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:collection/src/iterable_extensions.dart';

class _ActorTuple {
  final ActorRef ref;
  final ActorModel model;

  _ActorTuple(this.ref, this.model);
}

Map<String, List<ActorRef>> categorizeActorRefs(
    Map<ActorRef, ActorModel> actors) {
  if (actors.isEmpty) {
    return <String, List<ActorRef>>{};
  }

  // Take the list of Actors and group them based on the value of their
  // category property.
  final grouped = actors.entries.groupFoldBy<String, List<_ActorTuple>>(
      (entry) => entry.value.category,
      (previous, entry) => previous == null ? <_ActorTuple>[] : previous
        ..add(_ActorTuple(entry.key, entry.value)));

  // Sort the Actors in each Category alphabetically.
  grouped.forEach(
      (_, list) => list.sort((a, b) => a.model.name.compareTo(b.model.name)));

  // Now sort the Categorizes themselves alphabetically.
  final sortedCategories = grouped.keys.toList()..sort();

  // Now put that all back together.
  return Map<String, List<ActorRef>>.fromEntries(sortedCategories.map(
      (category) => MapEntry(
          category, grouped[category]!.map((tuple) => tuple.ref).toList())));
}
