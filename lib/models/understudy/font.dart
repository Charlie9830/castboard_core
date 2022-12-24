import 'dart:convert';

class UnderstudyFont {
  final String familyName;
  final bool isBuiltIn;
  final String source;

  UnderstudyFont({
    required this.familyName,
    required this.isBuiltIn,
    required this.source,
  });

  Map<String, dynamic> toMap() {
    return {
      'familyName': familyName,
      'isBuiltIn': isBuiltIn,
      'source': source,
    };
  }

  factory UnderstudyFont.fromMap(Map<String, dynamic> map) {
    return UnderstudyFont(
      familyName: map['familyName'] ?? '',
      isBuiltIn: map['isBuiltIn'] ?? false,
      source: map['source'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UnderstudyFont.fromJson(String source) =>
      UnderstudyFont.fromMap(json.decode(source));
}
