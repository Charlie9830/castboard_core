import 'package:castboard_core/elements/ActorElementModel.dart';
import 'package:castboard_core/elements/TextElementModel.dart';
import 'package:castboard_core/elements/TrackElementModel.dart';
import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/CastChangeModel.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackRef.dart';

String? lookupText(
  TextElementModel element,
  CastChangeModel? castChange,
  Map<ActorRef, ActorModel>? actors,
  Map<TrackRef, TrackModel>? tracks,
  Map<String, TrackRef> trackRefsByName,
) {
  if (element is ActorElementModel) {
    return lookupActorName(
        element.trackRef, element.subtitleFieldId, castChange, actors, tracks);
  }

  if (element is TrackElementModel) {
    return lookupTrackName(element.trackRef, castChange, actors, tracks);
  }

  if (element.needsInterpolation == true) {
    if (TextElementModel.matchInterpolationRegex.hasMatch(element.text) ==
        false) return 'NOT FOUND';

    String interpolated = element.text
        .replaceAllMapped(TextElementModel.matchInterpolationRegex, (match) {
      final matchText = match.group(0);

      if (matchText == null) return 'NOT FOUND';

      final trackName = matchText.replaceAll(
          TextElementModel.matchInterpolationOperatorsRegex, '');

      final trackRef = trackRefsByName[trackName];

      if (trackRef == null) {
        return 'NOT FOUND';
      }

      return lookupActorName(trackRef, "", castChange, actors, tracks) ??
          'NOT FOUND';
    });

    return interpolated;
  }

  return element.text;
}

String lookupTrackName(TrackRef trackRef, CastChangeModel? castChange,
    Map<ActorRef, ActorModel>? actors, Map<TrackRef, TrackModel>? tracks) {
  if (trackRef == const TrackRef.blank() ||
      tracks == null ||
      tracks.containsKey(trackRef) == false) {
    return 'Unassigned';
  }

  return tracks[trackRef]?.title ?? 'Untitled track';
}

String? lookupActorName(
    TrackRef trackRef,
    String subtitleFieldId,
    CastChangeModel? castChange,
    Map<ActorRef, ActorModel>? actors,
    Map<TrackRef, TrackModel>? tracks) {
  if (trackRef == const TrackRef.blank() ||
      tracks == null ||
      tracks.containsKey(trackRef) == false) {
    return 'Unassigned';
  }

  if (castChange == null) {
    return "Artist's name";
  }

  if (castChange.hasAssignment(trackRef) == false) {
    return "Artist's name";
  }

  final actor = actors![castChange.actorAt(trackRef)!];
  if (actor == null) {
    return "Artist missing";
  }

  // Check if this element should be displaying a Subtitle field and return the value of that field instead.
  if (subtitleFieldId.isNotEmpty) {
    return actor.subtitleValues[subtitleFieldId] ?? '';
  }

  return actor.name;
}
