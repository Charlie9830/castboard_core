import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorOrDividerViewModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/TrackIndex.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackOrIndexViewModel.dart';
import 'package:castboard_core/models/TrackRef.dart';
import 'package:castboard_core/utils/is_mobile_layout.dart';
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
  final Map<String, ActorTuple> assignments;
  final List<TrackOrDividerViewModel> trackViewModels;
  final Map<TrackRef, TrackModel> tracksByRef;
  final List<ActorOrDividerViewModel> actorViewModels;
  final Map<ActorRef, ActorModel> actorsByRef;
  final void Function(TrackRef track, ActorRef actor)? onAssignmentUpdated;
  final void Function(TrackRef track)? onResetLiveEdit;

  const CastChangeDetails({
    Key? key,
    this.assignments = const <String, ActorTuple>{},
    this.selfScrolling = true,
    this.trackViewModels = const <TrackOrDividerViewModel>[],
    required this.tracksByRef,
    this.actorViewModels = const <ActorOrDividerViewModel>[],
    required this.actorsByRef,
    this.onAssignmentUpdated,
    this.onResetLiveEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (trackViewModels.isEmpty && actorViewModels.isEmpty) {
      return const NoTracksOrArtistsFallback();
    }

    return ListView.builder(
      shrinkWrap: !selfScrolling,
      controller: ScrollController(),
      itemCount: trackViewModels.length,
      itemBuilder: (context, index) {
        final trackViewModel = trackViewModels[index];
        if (trackViewModel.type == TrackOrDividerViewModelType.track) {
          return _buildTrackRow(context, trackViewModel.trackModel!);
        } else {
          return _buildDivider(context, trackViewModel.divider!);
        }
      },
    );
  }

  Widget _buildTrackRow(BuildContext context, TrackModel track) {
    return Row(
      key: Key(track.ref.uid),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Track Title
        Expanded(
          child: Text(track.internalTitle,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: Theme.of(context).textTheme.bodyMedium),
        ),

        // Source Nested Preset Indicator.
        if (_fromNestedPreset(track.ref.uid, assignments) == true)
          Tooltip(
              message: _lookupSourcePresetName(track.ref.uid, assignments),
              waitDuration: const Duration(milliseconds: 250),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.call_merge,
                    color: Theme.of(context).disabledColor),
              )),

        // Live Edit Reset Button
        if (_fromLiveEdit(track.ref.uid, assignments) == true)
          TextButton(
            child: const Text('Reset'),
            onPressed: () => onResetLiveEdit?.call(track.ref),
          ),

        // Artist Selector
        Container(
          constraints: BoxConstraints.loose(const Size.fromWidth(150)),
          child: _buildDropdownButton(
            track,
            context,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context, TrackIndexDivider divider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
          child: Text(divider.title,
              style: Theme.of(context).textTheme.bodyMedium)),
    );
  }

  SearchDropdown _buildDropdownButton(TrackModel track, BuildContext context) {
    return SearchDropdown(
      selectedItemBuilder: (context) => _buildSelectedItem(context, track.ref),
      enabled: _fromNestedPreset(track.ref.uid, assignments) == false,
      onChanged: (actorRef) => onAssignmentUpdated?.call(
          track.ref, actorRef ?? const ActorRef.blank()),
      itemsBuilder: (context) {
        return [
          if (isMobileLayout(context) == false) ...<SearchDropdownItem>[
            _buildUnassignedOption(context),
            _buildTrackCutOption(context),
          ],
          ..._mapActorOptions(context),
        ];
      },
      specialOptionsBuilder: isMobileLayout(context)
          ? (context, onSelect) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                child: Row(
                  children: [
                    OutlinedButton(
                        child: const _TrackCutOption(),
                        onPressed: () => onSelect(const ActorRef.cut())),
                    const SizedBox(width: 8),
                    OutlinedButton(
                        child: const _UnassignedOption(),
                        onPressed: () => onSelect(const ActorRef.unassigned()))
                  ],
                ),
              );
            }
          : null,
    );
  }

  SearchDropdownItem? _buildSelectedItem(
    BuildContext context,
    TrackRef track,
  ) {
    final actorRef = _lookupValue(track.uid, assignments);

    if (actorRef == const ActorRef.unassigned()) {
      return _buildUnassignedOption(context);
    }

    if (actorRef == const ActorRef.cut()) {
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
        child: const _TrackCutOption(),
        value: const ActorRef.cut());
  }

  SearchDropdownItem _buildUnassignedOption(BuildContext context) {
    return SearchDropdownItem(
      keyword: 'Unassigned',
      child: const _UnassignedOption(),
      value: const ActorRef.unassigned(),
    );
  }

  List<SearchDropdownItem> _mapActorOptions(BuildContext context) {
    return actorViewModels.map((actorVm) {
      switch (actorVm.type) {
        case ActorOrDividerViewModelType.actor:
          final actor = actorVm.actorModel!;
          return SearchDropdownItem(
            keyword: actor.name,
            child: Text(actor.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium),
            value: actor.ref,
          );
        case ActorOrDividerViewModelType.divider:
          final divider = actorVm.divider!;

          return SearchDropdownItem(
              keyword: '',
              interactive: false,
              child: Text(divider.title,
                  style: Theme.of(context).textTheme.bodySmall),
              value: divider.uid);
      }
    }).toList();
  }

  ActorRef? _lookupValue(String? trackId, Map<String, ActorTuple> assignments) {
    if (assignments.containsKey(trackId)) {
      return assignments[trackId]!.actorRef;
    }

    return const ActorRef.unassigned();
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

class _UnassignedOption extends StatelessWidget {
  const _UnassignedOption({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.person_off,
          size: 16,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        Text('Unassigned',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.secondary)),
      ],
    );
  }
}

class _TrackCutOption extends StatelessWidget {
  const _TrackCutOption({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.content_cut,
          size: 16,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        Text('Track Cut',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.secondary)),
      ],
    );
  }
}
