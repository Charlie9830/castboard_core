import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

const String multicastAddress = '224.101.101.101';
const int discoveryPort = 8030;
const int unicastConnectivityPort = 8031;
final discoveryMagicBytes =
    Uint8List.fromList([77, 69, 79, 87, 84]); // Utf8 encoding of "MEOWT"
final discoveryReplyPayload = utf8.encode("castboard_performer");

const String kMdnsDeviceNamePrefix = "performer-";

bool hasMagicBytes(Uint8List other) {
  final header = other.take(discoveryMagicBytes.length);
  return const ListEquality().equals(discoveryMagicBytes, header.toList());
}
