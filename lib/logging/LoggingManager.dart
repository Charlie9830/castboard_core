import 'dart:collection';
import 'dart:io';

import 'package:castboard_core/logging/compressLogs.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as pathProvider;

const String _logFileExtension = '.log';
const String _logFileName = 'runlog';
const int _logFileSizeLimit = 1000000; // 1 megabyte.
const int _logFileMessageLimitMod = 1000;

class LoggingManager {
  static late LoggingManager _instance;
  static bool _initialized = false;

  late File _logFile;
  late IOSink? _logFileSink;

  late final _logFileDirName;

  // Forces the [LoggingManager] to run in release mode. Writing all [INFO] logs to file. Helpful for testing the LoggingManger
  // whilst in debug mode.
  late bool _runAsRelease;

  // Domain Loggers
  late Logger general;
  late Logger server;
  late Logger storage;
  late Logger player;
  late Logger systemManager;

  // Queue to catch and buffer any messages that come through whilst the IOSink is unavaiable (Such as when we are exporting it to file).
  final Queue<String> _messageQueue = Queue<String>();

  // Captures how many messages have been written to file. We use this to determine if it is time to switch to a new file.
  int _sessionMessageCount = 0;

  LoggingManager({
    required String directoryName,
    required File logFile,
    required IOSink logFileSink,
    required bool runAsRelease,
  }) {
    _logFileDirName = directoryName;
    _logFile = logFile;
    _logFileSink = logFileSink;
    _runAsRelease = runAsRelease;

    // Setup Logging library Stream Listeners.
    final Level logLevel = Level.ALL;

    general = Logger.detached('GENERAL')
      ..onRecord.listen(_handleLogRecord)
      ..level = logLevel;
    server = Logger.detached('SERVER')
      ..onRecord.listen(_handleLogRecord)
      ..level = logLevel;
    storage = Logger.detached('STORAGE')
      ..onRecord.listen(_handleLogRecord)
      ..level = logLevel;
    player = Logger.detached('PLAYER')
      ..onRecord.listen(_handleLogRecord)
      ..level = logLevel;
    systemManager = Logger.detached("SYSTEM_MANAGER")
      ..onRecord.listen(_handleLogRecord)
      ..level = logLevel;
  }

  static LoggingManager get instance {
    if (_initialized == false) {
      throw 'LoggingManager has not been initialized Yet. Ensure you are calling LoggingManager.initalize() prior to making any other calls';
    }

    return _instance;
  }

  static Future<void> initialize(String directoryName,
      {bool runAsRelease = false}) async {
    final file = await _getLogFile(directoryName);

    // ignore: close_sinks
    final sink = file.openWrite(mode: FileMode.append);

    _instance = LoggingManager(
      directoryName: directoryName,
      logFile: file,
      logFileSink: sink,
      runAsRelease: runAsRelease,
    );
    _initialized = true;
  }

  void exportLogs(String targetPath) async {
    final logsDir = await _getLogsDirectory(_logFileDirName);

    final List<String> logPaths = [];
    await for (var file in logsDir.list().where((entity) => entity is File)) {
      logPaths.add(file.path);
    }

    // Close the current Sink.
    await _closeSink();

    // Compress the Logs into Zip Format with an Isolate.
    await compute(
        compressLogs,
        CompressLogsParameters(
          logPaths: logPaths,
          targetFilePath: targetPath,
        ),
        debugLabel: 'Logfile Compression Isolate - compressLogs()');

    // Reopen the log file sink. And Flush any messages to it that may have come through whilst we were compressing and exporting.
    _logFile = await LoggingManager._getLogFile(_logFileDirName);
    _logFileSink = _logFile.openWrite(mode: FileMode.append);
    _flushMessageQueueToFile();
  }

  Future<void> _maybeEnumerateLogFile() async {
    if (await _logFile.length() > _logFileSizeLimit) {
      await _closeSink();
      _logFile = await LoggingManager._getLogFile(_logFileDirName);
      _logFileSink = _logFile.openWrite(mode: FileMode.append);
      _flushMessageQueueToFile();
    }
    return;
  }

  Future<void> _closeSink() async {
    if (_logFileSink == null) {
      return;
    }

    await _logFileSink!.flush();
    await _logFileSink!.close();
    _logFileSink = null;
  }

  void _handleLogRecord(LogRecord record) {
    if (record.level == Level.SEVERE) _handleSevereLog(record);

    if (record.level == Level.WARNING) _handleWarningLog(record);

    if (record.level == Level.INFO) _handleInfoLog(record);
  }

  void _handleSevereLog(LogRecord record) {
    if (_canThrowDebugExceptions) {
      _throwDebugException(record);
    } else {
      _write(_formatRecord(record));
    }
  }

  void _handleWarningLog(LogRecord record) {
    if (_canThrowDebugExceptions) {
      _throwDebugException(record);
    } else {
      _write(_formatRecord(record));
    }
  }

  void _handleInfoLog(LogRecord record) {
    if (_canThrowDebugExceptions) {
      // Don't need to spam the debug console with just [INFO] messages.
    } else {
      _write(_formatRecord(record));
    }
  }

  String _formatRecord(LogRecord record) {
    final String baseString =
        "\n[${record.level.name}] ${record.time} -- [${record.loggerName}] ${record.message}";

    if (record.stackTrace == null) {
      return baseString;
    } else {
      return baseString + "\n" + record.stackTrace!.toString() + "\n \n";
    }
  }

  /// Writes the provided message to the current log file sink. If that sink is closed, writes it to the [_messageQueue] instead.
  Future<void> _write(String message) async {
    if (_logFileSink == null) {
      // The Log File sink is currently closed. This could be because we are currently exporting it. Add the message to the Queue
      // in order to be appended to the file next time the Sink is opened.
      _messageQueue.add(message);
    } else {
      if (_checkFileSize()) {
        await _maybeEnumerateLogFile();
      }
      _logFileSink!.write(message);
    }
  }

  bool _checkFileSize() {
    return _sessionMessageCount % _logFileMessageLimitMod == 0;
  }

  void _throwDebugException(LogRecord record) {
    if (record.error != null) {
      throw record.error!;
    } else {
      print(_formatRecord(record));
    }
  }

  static Future<Directory> _getLogsDirectory(String directoryName) async {
    final docsDir = await pathProvider.getApplicationDocumentsDirectory();
    final logsDir = await Directory(p.join(
      docsDir.path,
      directoryName,
    )).create();

    return logsDir;
  }

  /// Searches for the latest log file. Latest being the file with the geatest log file number. Also checks that the current size of this
  /// file is below the 1mb limit. If so returns an IOSink pointing to that file,
  ///  if not creates and returns an IOSink to a new file.
  static Future<File> _getLogFile(String directoryName) async {
    final logsDir = await _getLogsDirectory(directoryName);
    final currentLastFileNumber = await _getLastFileNumber(logsDir);

    final fileCandidate = await File(p.join(
            logsDir.path, _getFormattedLogFileName(currentLastFileNumber)))
        .create();

    final int fileSize = await fileCandidate.length();

    if (fileSize < _logFileSizeLimit) {
      return fileCandidate;
    } else {
      // File to big. Enumerate to a new File.
      final newFile = await File(p.join(logsDir.path,
              _getFormattedLogFileName(currentLastFileNumber + 1)))
          .create();

      return newFile;
    }
  }

  void _flushMessageQueueToFile() async {
    if (_messageQueue.isEmpty || _logFileSink == null) {
      return;
    } else {
      final Iterable<Future<void>> writeRequests =
          _messageQueue.map((message) => _write(message));

      await Future.wait(writeRequests);
      return;
    }
  }

  static Future<int> _getLastFileNumber(Directory docsDir) async {
    final List<File> existingLogFiles = [];

    final isLogFile = (String path) => p.extension(path) == _logFileExtension;

    await for (var logFile
        in docsDir.list().where((entity) => isLogFile(entity.path))) {
      existingLogFiles.add(logFile as File);
    }

    if (existingLogFiles.isEmpty) {
      return 0;
    }

    // Sort by Log File Number.
    existingLogFiles.sort((a, b) =>
        _getLogFileNumber(p.basename(a.path)) -
        _getLogFileNumber(p.basename(b.path)));

    return _getLogFileNumber(p.basename(existingLogFiles.last.path));
  }

  /// Evaluates to true if running in Debug Mode OR [debugOverride] has been set to true in the constructor.
  bool get _canThrowDebugExceptions =>
      kDebugMode == true && _runAsRelease == false;

  static String _getFormattedLogFileName(int logFileNumber) {
    return '$_logFileName$logFileNumber$_logFileExtension';
  }

  static int _getLogFileNumber(String logFileName) {
    final trimmed = logFileName.replaceAll(r"\D", '');

    final int? result = int.tryParse(trimmed);

    if (result != null) {
      return result;
    } else {
      return 0;
    }
  }
}
