import 'dart:convert';

enum MessageType {
  unknown,
  payload,
  slideIndex,
  noShow,
}

class MessageModel {
  final MessageType type;
  final String payload;

  MessageModel({
    required this.type,
    required this.payload,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'payload': payload,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      type: _parseMessageType(map['type']),
      payload: map['payload'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source));
}

MessageType _parseMessageType(String? messageType) {
  switch (messageType) {
    case 'payload':
      return MessageType.payload;
    case 'slideIndex':
      return MessageType.slideIndex;
    case 'noShow':
      return MessageType.noShow;
  }

  return MessageType.unknown;
}
