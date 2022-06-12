import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/RemoteCastChangeData.dart';
import 'package:castboard_core/models/ShowDataModel.dart';
import 'package:castboard_core/models/ShowModificationData.dart';

class RemoteShowData {
  final ShowDataModel showData;
  final ShowModificationData? showModificationData;
  final PlaybackStateData playbackState;
  final ManifestModel? manifest;

  RemoteShowData({
    required this.showData,
    required this.playbackState,
    this.manifest,
    this.showModificationData,
  });

  Map<String, dynamic> toMap() {
    return {
      'showData': showData.toMap(),
      'playbackState': playbackState.toMap(),
      'showModificationData': showModificationData?.toMap() ??
          ShowModificationData.initial().toMap(),
      'manifest': manifest?.toMap(),
    };
  }

  factory RemoteShowData.fromMap(Map<String, dynamic> map) {
    return RemoteShowData(
      showData: ShowDataModel.fromMap(map['showData']),
      playbackState: PlaybackStateData.fromMap(map['playbackState']),
      showModificationData:
          ShowModificationData.fromMap(map['showModificationData']),
      manifest: map['manifest'] != null
          ? ManifestModel.fromMap(map['manifest'])
          : null,
    );
  }
}
