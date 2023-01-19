import 'dart:convert';

class SlideMetadataModel {
  final String slideId;
  final String slideName;
  final int index;

  SlideMetadataModel({
    this.slideId = '',
    this.slideName = '',
    this.index = 0,
  });

  SlideMetadataModel copyWith({
    String? slideId,
    String? slideName,
    int? index,
  }) {
    return SlideMetadataModel(
      slideId: slideId ?? this.slideId,
      slideName: slideName ?? this.slideName,
      index: index ?? this.index,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slideId': slideId,
      'slideName': slideName,
      'index': index,
    };
  }

  factory SlideMetadataModel.fromMap(Map<String, dynamic> map) {
    return SlideMetadataModel(
      slideId: map['slideId'] ?? '',
      slideName: map['slideName'] ?? '',
      index: map['index']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory SlideMetadataModel.fromJson(String source) =>
      SlideMetadataModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'SlideMetadataModel(slideId: $slideId, slideName: $slideName)';
}
