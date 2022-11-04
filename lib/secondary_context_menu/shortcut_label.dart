import 'dart:io';

class ShortcutLabel {
  static String get meta => Platform.isMacOS ? 'Cmd' : 'Ctrl';
  static String get copy => '$meta + C';
  static String get paste => '$meta + V';
  static String get group => '$meta + G';
  static String get ungroup => '$meta + U';
  static String get delete => 'Backspace/Delete';
  static String get selectAll => '$meta + A';
  static String get undo => '$meta + Z';
  static String get redo => '$meta + Y';
}
