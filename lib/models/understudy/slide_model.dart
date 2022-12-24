import 'dart:convert';

class UnderstudySlideModel {
  final double holdTime;
  final String html;

  UnderstudySlideModel({
    required this.holdTime,
    required this.html,
  });

  Map<String, dynamic> toMap() {
    return {
      'holdTime': holdTime,
      'html': html,
    };
  }

  factory UnderstudySlideModel.fromMap(Map<String, dynamic> map) {
    return UnderstudySlideModel(
      holdTime: map['holdTime']?.toDouble() ?? 5.0,
      html: map['html'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UnderstudySlideModel.fromJson(String source) =>
      UnderstudySlideModel.fromMap(json.decode(source));
}
