class TestException implements Exception {
  factory TestException() => const TestException._const();

  const TestException._const();
}

class UnexpectedException implements Exception {
  const UnexpectedException();
}

void safeCall(void Function() callable) {
  try {
    callable();
  } on Object catch (_) {}
}
