abstract class Logger {

  void log(String message);

  void logError(Object error, [StackTrace trace]);

}

class NoOpLogger implements Logger {

  factory NoOpLogger() => const NoOpLogger._const();

  const NoOpLogger._const();

  @override
  void log(String message) {
    // No-op
  }

  @override
  void logError(Object error, [StackTrace trace]) {
    // No-op
  }

}
