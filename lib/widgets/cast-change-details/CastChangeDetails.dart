import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
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
  final Map<TrackRef, TrackModel>? tracksByRef;
  final List<ActorModel> actors;
  final Map<ActorRef, ActorModel>? actorsByRef;
  final void Function(TrackRef track, ActorRef actor)? onAssignmentUpdated;
  final void Function(TrackRef track)? onResetLiveEdit;

  const CastChangeDetails({
    Key? key,
    this.assignments = const <String, ActorTuple>{},
    this.selfScrolling = true,
    this.allowNestedEditing = false,
    this.tracks = const <TrackModel>[],
    this.tracksByRef,
    this.actors = const <ActorModel>[],
    this.actorsByRef,
    this.onAssignmentUpdated,
    this.onResetLiveEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: !selfScrolling,
      children: tracks
          .map((track) => Row(
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
                        child: _buildDropdownButton(
                            allowNestedEditing, track, context),
                      ),
                    ],
                  )
                ],
              ))
          .toList(),
    );
  }

  DropdownButton<ActorRef> _buildDropdownButton(
      bool allowNestedEditing, TrackModel track, BuildContext context) {
    return DropdownButton<ActorRef>(
        isExpanded: true,
        value: _lookupValue(track.ref.uid, assignments),
        onChanged: allowNestedEditing == true ||
                _fromNestedPreset(track.ref.uid, assignments) == false
            ? (actorRef) => onAssignmentUpdated?.call(
                track.ref, actorRef ?? ActorRef.blank())
            : null,
        items: <DropdownMenuItem<ActorRef>>[
          _buildUnassignedOption(context),
          _buildTrackCutOption(context),
          ..._mapActorOptions(context),
        ]);
  }

  DropdownMenuItem<ActorRef> _buildTrackCutOption(BuildContext context) {
    return DropdownMenuItem<ActorRef>(
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

  DropdownMenuItem<ActorRef> _buildUnassignedOption(BuildContext context) {
    return DropdownMenuItem<ActorRef>(
      child: Text('Unassigned',
          style: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(color: Theme.of(context).colorScheme.secondary)),
      value: ActorRef.unassigned(),
    );
  }

  List<DropdownMenuItem<ActorRef>> _mapActorOptions(BuildContext context) {
    return actors
        .map((actor) => DropdownMenuItem<ActorRef>(
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
