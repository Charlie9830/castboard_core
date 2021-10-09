import 'package:castboard_core/enum-converters/systemCommandConverters.dart';
import 'package:castboard_core/system-commands/concreate-commands.dart';

enum SystemCommandType {
  none,
  reboot,
  powerOff,
  restartApplication,
}

abstract class SystemCommand {
  final SystemCommandType type;

  SystemCommand(this.type);

  factory SystemCommand.reboot() {
    return RebootSystemCommand();
  }

  factory SystemCommand.powerOff() {
    return PowerOffSystemCommand();
  }

  factory SystemCommand.restartApplication() {
    return RestartApplicationSystemCommand();
  }

  factory SystemCommand.fromMap(Map<String, dynamic> map) {
    final SystemCommandType incomingType = parseSystemCommandType(map['type']);

    switch (incomingType) {
      case SystemCommandType.none:
        return NoneSystemCommand();
      case SystemCommandType.reboot:
        return RebootSystemCommand();
      case SystemCommandType.powerOff:
        return PowerOffSystemCommand();
      case SystemCommandType.restartApplication:
        return RestartApplicationSystemCommand();
    }
  }

  Map<String, dynamic> toMap();
}
