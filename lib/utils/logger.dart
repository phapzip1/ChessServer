import "package:intl/intl.dart";

enum _LogType {
  info,
  warn,
  error,
}

class Logger {
  Logger._internal(bool timestamp, bool color)
      : _useTimestamp = timestamp,
        _format = DateFormat("H:m:s"),
        _useColor = color;
  static Logger? _instance;

  static void initialize({
    bool useTimestamp = true,
    bool useColor = true,
  }) =>
      _instance ??= Logger._internal(useTimestamp, useColor);

  static void warn(String message) => _instance?._log(message, _LogType.warn);
  static void info(String message) => _instance?._log(message, _LogType.info);
  static void error(String message) => _instance?._log(message, _LogType.error);

  // members
  bool _useTimestamp;
  set useTimestamp(bool value) => _useTimestamp = value;
  bool _useColor;
  set useColor(bool value) => _useColor = value;

  final DateFormat _format;

  static const _map = [96, 93, 91];

  void _log(String message, _LogType type) => print(
      "${_useColor ? "\x1B[${_map[type.index]}m" : ""}${_useTimestamp ? "[${_format.format(DateTime.now())}] " : ""}$message\x1B[0m");
}
