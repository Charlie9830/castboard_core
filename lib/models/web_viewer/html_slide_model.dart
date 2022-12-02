import 'dart:convert';

class HTMLSlideModel {
  final double holdTime;
  final String html;

  HTMLSlideModel({
    required this.holdTime,
    required this.html,
  });

  Map<String, dynamic> toMap() {
    return {
      'holdTime': holdTime,
      'html': html,
    };
  }

  factory HTMLSlideModel.fromMap(Map<String, dynamic> map) {
    return HTMLSlideModel(
      holdTime: map['holdTime']?.toDouble() ?? 5.0,
      html: map['html'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory HTMLSlideModel.fromJson(String source) =>
      HTMLSlideModel.fromMap(json.decode(source));
}
