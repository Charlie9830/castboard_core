import 'package:castboard_core/models/TrackIndex.dart';
import 'package:castboard_core/models/TrackModel.dart';

enum TrackOrDividerViewModelType {
  track,
  divider,
}

class TrackOrDividerViewModel {
  final TrackOrDividerViewModelType type;
  final TrackIndex? trackIndex;
  final TrackModel? trackModel;
  final TrackIndexDivider? divider;

  TrackOrDividerViewModel({
    required this.type,
    this.trackIndex,
    this.trackModel,
    this.divider,
  });
}
