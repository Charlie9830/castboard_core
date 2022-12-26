import 'dart:convert';

enum UnderstudyMessageType {
  unknown,
  payload,
  slideIndex,
  noShow,
  clientId,
}

class UnderstudyMessageModel {
  final UnderstudyMessageType type;
  final String payload;

  UnderstudyMessageModel({
    required this.type,
    required this.payload,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'payload': payload,
    };
  }

  factory UnderstudyMessageModel.fromMap(Map<String, dynamic> map) {
    return UnderstudyMessageModel(
      type: _parseMessageType(map['type']),
      payload: map['payload'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UnderstudyMessageModel.fromJson(String source) =>
      UnderstudyMessageModel.fromMap(json.decode(source));
}

UnderstudyMessageType _parseMessageType(String? messageType) {
  switch (messageType) {
    case 'payload':
      return UnderstudyMessageType.payload;
    case 'slideIndex':
      return UnderstudyMessageType.slideIndex;
    case 'noShow':
      return UnderstudyMessageType.noShow;
    case 'clientId':
      return UnderstudyMessageType.clientId;
  }

  return UnderstudyMessageType.unknown;
}
