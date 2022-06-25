import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackOrIndexViewModel.dart';
import 'package:castboard_core/models/TrackRef.dart';

/// [TrackIndexBase] provides the base class for which [TrackIndex] and [TrackIndexDivider] derive from.
/// [TrackIndex] and [TrackIndexDivider] are stored in state as a List and represent the position of each
/// Track Model and Divider within the collection of Tracks. This allows for custom sort orders of Tracks and
/// the associated Dividers.

const String _trackType = 'track';
const String _dividerType = 'divider';

abstract class TrackIndexBase {
  final String type;

  TrackIndexBase(this.type);

  factory TrackIndexBase.fromMap(Map<String, dynamic> map) {
    final String type = map['type'];

    if (type == _trackType) {
      return TrackIndex.fromMap(map);
    } else {
      return TrackIndexDivider.fromMap(map);
    }
  }

  Map<String, dynamic> toMap();

  static List<TrackOrDividerViewModel> toViewModels(
      Map<TrackRef, TrackModel> tracks, List<TrackIndexBase> trackIndex) {
    return trackIndex.map((item) {
      if (item is TrackIndex) {
        return item.toViewModel(tracks[item.ref]!);
      }

      if (item is TrackIndexDivider) {
        return item.toViewModel();
      }

      throw UnsupportedError(
          'TrackIndexBase.toViewModels is missing handling for an TrackIndexBase item of type ${item.runtimeType}.');
    }).toList();
  }
}

class TrackIndex extends TrackIndexBase {
  final TrackRef ref;

  TrackIndex(
    this.ref,
  ) : super(_trackType);

  factory TrackIndex.fromMap(Map<String, dynamic> map) {
    return TrackIndex(
      TrackRef.fromMap(map['ref']),
    );
  }

  TrackOrDividerViewModel toViewModel(TrackModel trackModel) {
    return TrackOrDividerViewModel(
        type: TrackOrDividerViewModelType.track,
        trackIndex: this,
        trackModel: trackModel);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'ref': ref.toMap(),
    };
  }
}

class TrackIndexDivider extends TrackIndexBase {
  final String uid;
  final String title;

  TrackIndexDivider(this.uid, this.title) : super(_dividerType);

  factory TrackIndexDivider.fromMap(Map<String, dynamic> map) {
    return TrackIndexDivider(
      map['uid'] ?? '',
      map['title'] ?? '',
    );
  }

  TrackOrDividerViewModel toViewModel() {
    return TrackOrDividerViewModel(
        type: TrackOrDividerViewModelType.divider, divider: this);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'uid': uid,
      'title': title,
    };
  }

  TrackIndexDivider copyWith({
    String? uid,
    String? title,
  }) {
    return TrackIndexDivider(
      uid ?? this.uid,
      title ?? this.title,
    );
  }
}
