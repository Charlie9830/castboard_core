import 'dart:convert';

class WebViewerFont {
  final String familyName;
  final bool isBuiltIn;
  final String source;

  WebViewerFont({
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

  factory WebViewerFont.fromMap(Map<String, dynamic> map) {
    return WebViewerFont(
      familyName: map['familyName'] ?? '',
      isBuiltIn: map['isBuiltIn'] ?? false,
      source: map['source'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory WebViewerFont.fromJson(String source) =>
      WebViewerFont.fromMap(json.decode(source));
}
