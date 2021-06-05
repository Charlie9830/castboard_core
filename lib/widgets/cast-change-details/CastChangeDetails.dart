import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/widgets/SearchDropdown.dart';
import 'package:flutter/material.dart';

class ActorTuple {
  final ActorRef? actorRef;
  final String? sourcePresetName;
  final bool? fromLiveEdit;
  final bool? fromNestedPreset;

  ActorTuple({
    this.actorRef,
    this.sourcePresetName,
    this.fromLiveEdit = false,
    this.fromNestedPreset,
  });
}

class CastChangeDetails extends StatelessWidget {
  final bool selfScrolling;
  final bool allowNestedEditing;
  final Map<String, ActorTuple> assignments;
  final List<TrackModel> tracks;
  final Map<TrackRef, TrackModel> tracksByRef;
  final List<ActorModel> actors;
  final Map<ActorRef, ActorModel> actorsByRef;
  final void Function(TrackRef track, ActorRef actor)? onAssignmentUpdated;
  final void Function(TrackRef track)? onResetLiveEdit;

  const CastChangeDetails({
    Key? key,
    this.assignments = const <String, ActorTuple>{},
    this.selfScrolling = true,
    this.allowNestedEditing = false,
    this.tracks = const <TrackModel>[],
    required this.tracksByRef,
    this.actors = const <ActorModel>[],
    required this.actorsByRef,
    this.onAssignmentUpdated,
    this.onResetLiveEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: !selfScrolling,
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return Row(
          key: Key(track.ref.uid),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(track.internalTitle,
                style: Theme.of(context).textTheme.bodyText2),
            Row(
              children: [
                if (_fromLiveEdit(track.ref.uid, assignments) == true)
                  TextButton(
                    child: Text('Reset'),
                    onPressed: () => onResetLiveEdit?.call(track.ref),
                  ),
                if (_fromNestedPreset(track.ref.uid, assignments) == true)
                  Row(
                    children: [
                      Text(
                          'From ${_lookupSourcePresetName(track.ref.uid, assignments)}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.caption),
                      SizedBox(width: 24),
                    ],
                  ),
                Container(
                  constraints: BoxConstraints.loose(Size.fromWidth(150)),
                  child:
                      _buildDropdownButton(allowNestedEditing, track, context),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  SearchDropdown _buildDropdownButton(
      bool allowNestedEditing, TrackModel track, BuildContext context) {
    return SearchDropdown(
      selectedItemBuilder: (context) => _buildSelectedItem(context, track.ref),
      enabled: allowNestedEditing == true ||
          _fromNestedPreset(track.ref.uid, assignments) == false,
      onChanged: (actorRef) =>
          onAssignmentUpdated?.call(track.ref, actorRef ?? ActorRef.blank()),
      itemsBuilder: (context) {
        return [
          _buildUnassignedOption(context),
          _buildTrackCutOption(context),
          ..._mapActorOptions(context),
        ];
      },
    );
  }

  SearchDropdownItem? _buildSelectedItem(
    BuildContext context,
    TrackRef track,
  ) {
    final actorRef = _lookupValue(track.uid, assignments);

    if (actorRef == ActorRef.unassigned()) {
      return _buildUnassignedOption(context);
    }

    if (actorRef == ActorRef.cut()) {
      return _buildTrackCutOption(context);
    }

    final actor = actorsByRef[actorRef];

    if (actor == null) {
      return null;
    }

    return SearchDropdownItem(
      keyword: actor.name,
      value: actor.ref,
      child: Text(actor.name),
    );
  }

  SearchDropdownItem _buildTrackCutOption(BuildContext context) {
    return SearchDropdownItem(
        keyword: 'Track Cut',
        child: Row(
          children: [
            Icon(
              Icons.content_cut,
              size: 16,
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(width: 8),
            Text('Track Cut',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(color: Theme.of(context).colorScheme.secondary)),
          ],
        ),
        value: ActorRef.cut());
  }

  SearchDropdownItem _buildUnassignedOption(BuildContext context) {
    return SearchDropdownItem(
      keyword: 'Unassigned',
      child: Row(
        children: [
          Icon(
            Icons.person_off,
            size: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(width: 8),
          Text('Unassigned',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: Theme.of(context).colorScheme.secondary)),
        ],
      ),
      value: ActorRef.unassigned(),
    );
  }

  List<SearchDropdownItem> _mapActorOptions(BuildContext context) {
    return actors
        .map((actor) => SearchDropdownItem(
              keyword: actor.name,
              child: Text(actor.name,
                  style: Theme.of(context).textTheme.bodyText2),
              value: actor.ref,
            ))
        .toList();
  }

  ActorRef? _lookupValue(String? trackId, Map<String, ActorTuple> assignments) {
    if (assignments.containsKey(trackId)) {
      return assignments[trackId]!.actorRef;
    }

    return ActorRef.unassigned();
  }

  bool _fromNestedPreset(String? trackId, Map<String, ActorTuple> assignments) {
    if (assignments.containsKey(trackId)) {
      return assignments[trackId]!.fromNestedPreset ?? false;
    }

    return false;
  }

  bool _fromLiveEdit(String? trackId, Map<String, ActorTuple> assignments) {
    if (assignments.containsKey(trackId)) {
      return assignments[trackId]!.fromLiveEdit ?? false;
    }

    return false;
  }

  String _lookupSourcePresetName(
      String? trackId, Map<String, ActorTuple> assignments) {
    return assignments[trackId]?.sourcePresetName ?? '';
  }
}
