import 'package:estd/logger.dart';
import 'package:flutter/foundation.dart';

class FlutterLogger implements Logger {
  const FlutterLogger();

  @override
  void log(String message) {
    debugPrint(message);
  }

  @override
  void logError(Object error, [StackTrace trace]) {
    log(error.toString());
    if (trace != null) log(trace.toString());
  }
}
