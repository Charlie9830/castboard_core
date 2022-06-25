import 'package:castboard_core/models/TrackRef.dart';

class TrackModel {
  final TrackRef ref;
  final String title;
  final String internalTitle;

  TrackModel({
    required this.ref,
    this.title = '',
    this.internalTitle = '',
  });

  TrackModel copyWith({
    TrackRef? ref,
    String? title,
    String? internalTitle,
  }) {
    return TrackModel(
      ref: ref ?? this.ref,
      title: title ?? this.title,
      internalTitle: internalTitle ?? this.internalTitle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ref': ref.toMap(),
      'title': title,
      'internalTitle': internalTitle,
    };
  }

  factory TrackModel.fromMap(Map<String, dynamic> map) {
    return TrackModel(
      ref: TrackRef.fromMap(map['ref']),
      title: map['title'],
      internalTitle: map['internalTitle'],
    );
  }
}
