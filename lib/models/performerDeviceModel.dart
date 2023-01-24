import 'dart:convert';

import 'package:castboard_core/enum-converters/performerConnectivityStateConverters.dart';

enum PerformerConnectivityState { partial, full, disconnected }

const kPerformerDeviceValidationKeyValue = 'fool-of-a-took!';

class PerformerDeviceModel {
  final String validationKey = kPerformerDeviceValidationKeyValue;
  final String ipAddress;
  final int port;
  final PerformerConnectivityState connectivityState;
  final String deviceName = 'Performer';
  final String deviceId;
  final String showName;
  final String softwareVersion;
  final String hostName;

  PerformerDeviceModel({
    required this.ipAddress,
    required this.port,
    required this.connectivityState,
    required this.showName,
    required this.softwareVersion,
    required this.deviceId,
    required this.hostName,
  });

  PerformerDeviceModel.partial({
    required this.ipAddress,
    required this.port,
    required this.deviceId,
  })  : connectivityState = PerformerConnectivityState.partial,
        showName = '',
        softwareVersion = '',
        hostName = '';

  /// Fills out only [deviceName], [deviceId] [showName] and [softwareVersion]. All other values are throwaways.
  PerformerDeviceModel.detailsOnly({
    required this.showName,
    required this.softwareVersion,
    required this.deviceId,
  })  : connectivityState = PerformerConnectivityState.partial,
        ipAddress = '0.0.0.0',
        port = 0,
        hostName = '';

  Map<String, dynamic> toMap() {
    return {
      'validationKey': validationKey,
      'ipAddress': ipAddress,
      'port': port,
      'connectivityState': convertPerformerConnectivityState(connectivityState),
      'deviceName': deviceName,
      'showName': showName,
      'softwareVersion': softwareVersion,
      'deviceId': deviceId,
      'hostName': hostName,
    };
  }

  factory PerformerDeviceModel.fromMap(Map<String, dynamic> map) {
    return PerformerDeviceModel(
      ipAddress: map['ipAddress'] ?? '',
      port: map['port']?.toInt() ?? 0,
      connectivityState:
          parsePerformerConnectivityState(map['connectivityState']),
      showName: map['showName'] ?? '',
      softwareVersion: map['softwareVersion'] ?? '',
      deviceId: map['deviceId'] ?? '',
      hostName: map['hostName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PerformerDeviceModel.fromJson(String source) =>
      PerformerDeviceModel.fromMap(json.decode(source));

  PerformerDeviceModel copyWith({
    String? ipAddress,
    int? port,
    PerformerConnectivityState? connectivityState,
    String? deviceName,
    String? showName,
    String? softwareVersion,
    String? deviceId,
    String? hostName,
  }) {
    return PerformerDeviceModel(
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      connectivityState: connectivityState ?? this.connectivityState,
      showName: showName ?? this.showName,
      softwareVersion: softwareVersion ?? this.softwareVersion,
      deviceId: deviceId ?? this.deviceId,
      hostName: hostName ?? this.hostName,
    );
  }

  @override
  String toString() {
    return '[Performer Device] IP: $ipAddress  Port: $port   State: $connectivityState   deviceId: $deviceId';
  }
}
