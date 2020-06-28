class TestException implements Exception {
  factory TestException() => const TestException._const();

  const TestException._const();
}
