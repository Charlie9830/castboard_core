import 'package:castboard_core/enum-converters/EnumConversionError.dart';
import 'package:castboard_core/models/performerDeviceModel.dart';

PerformerConnectivityState parsePerformerConnectivityState(String value) {
  switch (value) {
    case 'partial':
      return PerformerConnectivityState.partial;
    case 'full':
      return PerformerConnectivityState.full;
    default:
      throw EnumConversionError(
          'Unknown value when trying to parse String into PerformerConnectivityState. Unknown value is $value');
  }
}

String convertPerformerConnectivityState(PerformerConnectivityState value) {
  switch (value) {
    case PerformerConnectivityState.partial:
      return 'partial';
    case PerformerConnectivityState.full:
      return 'full';
    default:
      return 'partial';
  }
}
