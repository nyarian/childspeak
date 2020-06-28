import 'dart:math';

final Random random = Random();

int randomInt() => random.nextInt(1 << 32);

int randomBoundedInt(int max) => random.nextInt(max);

double randomDouble() => random.nextDouble();

bool randomBool() => random.nextBool();

String randomString() => randomInt().toString();

DateTime randomDateTime() => DateTime(
  randomBoundedInt(50) + 1970,
  randomBoundedInt(12) + 1,
  randomBoundedInt(28) + 1,
  randomBoundedInt(24),
  randomBoundedInt(60),
  randomBoundedInt(60),
  randomBoundedInt(1000),
  randomBoundedInt(1000),
);
