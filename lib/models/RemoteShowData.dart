import 'package:castboard_core/models/ActorRef.dart';
import 'package:castboard_core/models/ManifestModel.dart';
import 'package:castboard_core/models/RemoteCastChangeData.dart';
import 'package:castboard_core/models/ShowDataModel.dart';
import 'package:castboard_core/models/ShowModificationData.dart';

class RemoteShowData {
  final ShowDataModel showData;
  final ShowModificationData? showModificationData;
  final PlaybackStateData playbackState;
  final ManifestModel? manifest;
  final Map<String, List<ActorRef>>? categorizedActorRefs;

  RemoteShowData({
    required this.showData,
    required this.playbackState,
    this.manifest,
    this.showModificationData,
    this.categorizedActorRefs,
  });

  Map<String, dynamic> toMap() {
    return {
      'showData': showData.toMap(),
      'playbackState': playbackState.toMap(),
      'showModificationData': showModificationData?.toMap() ??
          ShowModificationData.initial().toMap(),
      'manifest': manifest?.toMap(),
      'categorizedActorRefs': categorizedActorRefs == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.fromEntries(categorizedActorRefs!.entries.map(
              (entry) => MapEntry(
                  entry.key, entry.value.map((ref) => ref.toMap()).toList())))
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
      categorizedActorRefs: map['categorizedActorRefs'] == null
          ? null
          : Map<String, List<ActorRef>>.fromEntries(
              (map['categorizedActorRefs'] as Map<String, dynamic>).entries.map(
                    (entry) => MapEntry(
                      entry.key,
                      (entry.value as List<dynamic>)
                          .map((item) => ActorRef.fromMap(item))
                          .toList(),
                    ),
                  ),
            ),
    );
  }
}
