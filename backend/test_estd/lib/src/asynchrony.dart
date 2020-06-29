Future<void> reschedule({int times}) async {
  if (times == null) {
    return Future<void>.value();
  } else if (times < 1) {
    throw ArgumentError('Times cannot be less then 1');
  } else {
    for (var i = 0; i < times; i++) {
      await reschedule();
    }
  }
}

Future<void> suspend(Duration duration) => Future<void>.delayed(duration);

Future<void> suspendMillis(int milliseconds) =>
    Future<void>.delayed(Duration(milliseconds: milliseconds));

extension FutureExt<T> on T {
  Future<T> asFuture() => Future<T>.value(this);
}

extension FutureError on Error {
  Future<T> asFutureError<T>() => Future<T>.error(this);
}

extension FutureException on Exception {
  Future<T> asFutureError<T>() => Future<T>.error(this);
}

extension StreamExtension<T> on T {
  Stream<T> asStreamValue() => Stream<T>.value(this);
}

extension StreamException on Exception {
  Stream<T> asStreamException<T>() => Stream<T>.error(this);
}

extension StreamError on Error {
  Stream<T> asStreamError<T>() => Stream<T>.error(this);
}
