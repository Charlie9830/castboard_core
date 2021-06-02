import 'package:castboard_core/models/ActorModel.dart';
import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/PresetModel.dart';
import 'package:castboard_core/models/RemoteCastChangeData.dart';
import 'package:castboard_core/models/ShowDataModel.dart';
import 'package:castboard_core/models/ShowModificationData.dart';
import 'package:castboard_core/models/TrackModel.dart';
import 'package:castboard_core/models/TrackRef.dart';

class RemoteShowData {
  final ShowDataModel showData;
  final ShowModificationData? showModificationData;
  final PlaybackStateData playbackState;

  RemoteShowData({
    required this.showData,
    required this.playbackState,
    this.showModificationData,
  });

  Map<String, dynamic> toMap() {
    return {
      'showData': showData.toMap(),
      'playbackState': playbackState.toMap(),
      'showModificationData': showModificationData?.toMap() ??
          ShowModificationData.initial().toMap(),
    };
  }

  factory RemoteShowData.fromMap(Map<String, dynamic> map) {
    return RemoteShowData(
      showData: ShowDataModel.fromMap(map['showData']),
      playbackState: PlaybackStateData.fromMap(map['playbackState']),
      showModificationData:
          ShowModificationData.fromMap(map['showModificationData']),
    );
  }
}
