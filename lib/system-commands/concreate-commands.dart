import 'package:castboard_core/enum-converters/systemCommandConverters.dart';
import 'package:castboard_core/system-commands/SystemCommands.dart';

class NoneSystemCommand extends SystemCommand {
  NoneSystemCommand() : super(SystemCommandType.none);

  @override
  Map<String, dynamic> toMap() {
    return _noArgsToMapShim(super.type);
  }
}

class RebootSystemCommand extends SystemCommand {
  RebootSystemCommand() : super(SystemCommandType.reboot);

  @override
  Map<String, dynamic> toMap() {
    return _noArgsToMapShim(super.type);
  }
}

class PowerOffSystemCommand extends SystemCommand {
  PowerOffSystemCommand() : super(SystemCommandType.powerOff);

  @override
  Map<String, dynamic> toMap() {
    return _noArgsToMapShim(super.type);
  }
}

class RestartApplicationSystemCommand extends SystemCommand {
  RestartApplicationSystemCommand()
      : super(SystemCommandType.restartApplication);

  @override
  Map<String, dynamic> toMap() {
    return _noArgsToMapShim(super.type);
  }
}

Map<String, dynamic> _noArgsToMapShim(SystemCommandType type) {
  return <String, dynamic>{
    'type': convertSystemCommandType(type),
  };
}
