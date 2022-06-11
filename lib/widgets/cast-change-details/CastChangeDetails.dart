import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/widgets/SearchDropdown.dart';
import 'package:castboard_core/widgets/cast-change-details/NoTracksOrArtistsFallback.dart';
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
  final Map<String, List<ActorRef>> categorizedActorRefs;
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
    this.categorizedActorRefs = const {},
    required this.actorsByRef,
    this.onAssignmentUpdated,
    this.onResetLiveEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty && actors.isEmpty) {
      return NoTracksOrArtistsFallback();
    }

    return ListView.builder(
      shrinkWrap: !selfScrolling,
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return Row(
          key: Key(track.ref.uid),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Track Title
            Expanded(
              child: Text(track.internalTitle,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodyText2),
            ),

            // Source Nested Preset Indicator.
            if (_fromNestedPreset(track.ref.uid, assignments) == true)
              Tooltip(
                  message: _lookupSourcePresetName(track.ref.uid, assignments),
                  waitDuration: Duration(milliseconds: 250),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.call_merge,
                        color: Theme.of(context).disabledColor),
                  )),

            // Live Edit Reset Button
            if (_fromLiveEdit(track.ref.uid, assignments) == true)
              TextButton(
                child: Text('Reset'),
                onPressed: () => onResetLiveEdit?.call(track.ref),
              ),

            // Artist Selector
            Container(
              constraints: BoxConstraints.loose(Size.fromWidth(150)),
              child: _buildDropdownButton(
                allowNestedEditing,
                track,
                context,
              ),
            ),
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
      child: Text(
        actor.name,
        overflow: TextOverflow.ellipsis,
      ),
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
    return categorizedActorRefs.entries.fold(
        <SearchDropdownItem>[],
        (existing, entry) => existing
          ..addAll([
            _buildCategoryTitleSearchDropdownItem(context, entry.key),
            ...entry.value
                .map((ref) =>
                    _buildActorSearchDropdownItem(context, actorsByRef[ref]!))
                .toList()
          ]));
  }

  SearchDropdownItem _buildActorSearchDropdownItem(
      BuildContext context, ActorModel actor) {
    return SearchDropdownItem(
      keyword: '${actor.name} ${actor.category}',
      child: Text(actor.name,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyText2),
      value: actor.ref,
    );
  }

  SearchDropdownItem _buildCategoryTitleSearchDropdownItem(
      BuildContext context, String title) {
    return SearchDropdownItem(
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(color: Colors.grey.shade400),
        ),
        interactive: false,
        keyword: '',
        value: '');
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
