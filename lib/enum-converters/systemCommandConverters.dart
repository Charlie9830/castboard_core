import 'package:castboard_core/enum-converters/EnumConversionError.dart';
import 'package:castboard_core/system-commands/SystemCommands.dart';

SystemCommandType parseSystemCommandType(String? value) {
  if (value == null || value == 'none' || value.isEmpty) {
    return SystemCommandType.none;
  }

  if (value == 'powerOff') {
    return SystemCommandType.powerOff;
  }

  if (value == 'reboot') {
    return SystemCommandType.reboot;
  }

  if (value == 'restartApplication') {
    return SystemCommandType.restartApplication;
  }

  throw EnumConversionError(
      'Unknown value when trying to parse String into SystemCommandType. Unknown value is $value');
}

String convertSystemCommandType(SystemCommandType value) {
  switch (value) {
    case SystemCommandType.none:
      return 'none';
    case SystemCommandType.powerOff:
      return 'powerOff';
    case SystemCommandType.reboot:
      return 'reboot';
    case SystemCommandType.restartApplication:
      return 'restartApplication';

    default:
      throw EnumConversionError(
          'Unknown value when trying to convert SystemCommandType into String. Unknown value is $value');
  }
}
