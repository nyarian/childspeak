import 'package:estd/logger.dart';

class ForbiddenLogger implements Logger {

  factory ForbiddenLogger() => const ForbiddenLogger._singleton();

  const ForbiddenLogger._singleton();

  @override
  void log(String message) => throw LoggingForbiddenError();

  @override
  void logError(Object error, [StackTrace trace]) =>
      throw LoggingForbiddenError();
}

class LoggingForbiddenError extends Error {}
