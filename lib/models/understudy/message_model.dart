import 'dart:convert';

enum UnderstudyMessageType {
  unknown,
  initialPayload, // Represents the payload sent to an Understudy client when it's session has started.
  contentChange, // Represents the payload sent to an Understudy client when a change to the content slides has been made (cast change)
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
    case 'initialPayload':
      return UnderstudyMessageType.initialPayload;
    case 'contentChange':
      return UnderstudyMessageType.contentChange;
    case 'slideIndex':
      return UnderstudyMessageType.slideIndex;
    case 'noShow':
      return UnderstudyMessageType.noShow;
    case 'clientId':
      return UnderstudyMessageType.clientId;
  }

  return UnderstudyMessageType.unknown;
}
