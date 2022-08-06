import 'dart:convert';

import 'package:castboard_core/enum-converters/performerConnectivityStateConverters.dart';

enum PerformerConnectivityState { partial, full }

const kPerformerDeviceValidationKeyValue = 'fool-of-a-took!';

class PerformerDeviceModel {
  final String validationKey = kPerformerDeviceValidationKeyValue;
  final String ipAddress;
  final int port;
  final PerformerConnectivityState connectivityState;
  final String deviceName;
  final String showName;
  final String softwareVersion;
  final Set<String> discoveryMethods;

  PerformerDeviceModel({
    required this.ipAddress,
    required this.port,
    required this.connectivityState,
    required this.deviceName,
    required this.showName,
    required this.softwareVersion,
    required this.discoveryMethods,
  });

  PerformerDeviceModel.partial({
    required this.ipAddress,
    required this.port,
    required this.discoveryMethods,
  })  : connectivityState = PerformerConnectivityState.partial,
        deviceName = '',
        showName = '',
        softwareVersion = '';

  /// Fills out only [deviceName], [showName] and [softwareVersion]. All other values are throwaways.
  PerformerDeviceModel.detailsOnly({
    required this.deviceName,
    required this.showName,
    required this.softwareVersion,
  })  : connectivityState = PerformerConnectivityState.partial,
        ipAddress = '0.0.0.0',
        port = 0,
        discoveryMethods = {};

  Map<String, dynamic> toMap() {
    return {
      'validationKey': validationKey,
      'ipAddress': ipAddress,
      'port': port,
      'connectivityState': convertPerformerConnectivityState(connectivityState),
      'deviceName': deviceName,
      'showName': showName,
      'softwareVersion': softwareVersion,
    };
  }

  factory PerformerDeviceModel.fromMap(
      Map<String, dynamic> map, Set<String> discoveryMethods) {
    return PerformerDeviceModel(
      ipAddress: map['ipAddress'] ?? '',
      port: map['port']?.toInt() ?? 0,
      connectivityState:
          parsePerformerConnectivityState(map['connectivityState']),
      deviceName: map['deviceName'] ?? '',
      showName: map['showName'] ?? '',
      softwareVersion: map['softwareVersion'] ?? '',
      discoveryMethods: discoveryMethods,
    );
  }

  String toJson() => json.encode(toMap());

  factory PerformerDeviceModel.fromJson(
          String source, Set<String> discoveryMethods) =>
      PerformerDeviceModel.fromMap(json.decode(source), discoveryMethods);

  PerformerDeviceModel copyWith({
    String? ipAddress,
    int? port,
    PerformerConnectivityState? connectivityState,
    String? deviceName,
    String? showName,
    String? softwareVersion,
    Set<String>? discoveryMethods,
  }) {
    return PerformerDeviceModel(
        ipAddress: ipAddress ?? this.ipAddress,
        port: port ?? this.port,
        connectivityState: connectivityState ?? this.connectivityState,
        deviceName: deviceName ?? this.deviceName,
        showName: showName ?? this.showName,
        softwareVersion: softwareVersion ?? this.softwareVersion,
        discoveryMethods: discoveryMethods == null
            ? this.discoveryMethods
            : {...this.discoveryMethods, ...discoveryMethods});
  }
}
