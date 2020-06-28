import 'package:bloc/entity/entity.dart';
import 'package:bloc/entity/facade.dart';
import 'package:domain/entity.dart';
import 'package:estd/logger.dart';
import 'package:test_estd/test_estd.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  final facade = MockEntitiesFacade();

  tearDown(() {
    reset(facade);
  });

  EntitiesBloc createTestSubject() => EntitiesBloc(facade, NoOpLogger());

  test('assert that newly constructed bloc does not emit anything', () async {
    when(facade.getAll()).thenThrow(TestException());
    final subject = EntitiesBloc(facade, ForbiddenLogger());
    await suspendMillis(20);
    expect(subject.state, emitsInOrder(<dynamic>[]));
  }, timeout: const Timeout(Duration(seconds: 1)));

  test('assert that retrieving state was emitted initially on refresh',
      () async {
    when(facade.getAll()).thenAnswer((_) async => const <Entity>[]);
    final subject = createTestSubject()..refresh();
    expect(
        subject.state,
        emitsInOrder(<dynamic>[
          predicate<EntitiesState>((state) => state.isRetrievingEntities),
        ]));
  }, timeout: const Timeout(Duration(seconds: 1)));

  test(
      'assert that successful and non-loading state was emitted after '
      'receiving the facade response', () async {
    when(facade.getAll()).thenAnswer((_) async => const <Entity>[]);
    final subject = createTestSubject()..refresh();
    await suspendMillis(5);
    expect(
        subject.state,
        emitsInOrder(<dynamic>[
          predicate<EntitiesState>(
              (state) => !state.isRetrievingEntities && state.entities != null),
        ]));
  }, timeout: const Timeout(Duration(seconds: 1)));

  test('assert that state is empty if getAll() returns empty list', () async {
    when(facade.getAll()).thenAnswer((_) async => const <Entity>[]);
    final subject = createTestSubject()..refresh();
    await suspendMillis(5);
    expect(
        subject.state,
        emitsInOrder(<dynamic>[
          predicate<EntitiesState>((state) => state.isEmpty()),
        ]));
  }, timeout: const Timeout(Duration(seconds: 1)));

  test('assert that state is not empty if getAll() returns non-empty list',
      () async {
    when(facade.getAll()).thenAnswer((_) async => <Entity>[MockEntity()]);
    final subject = createTestSubject()..refresh();
    await suspendMillis(5);
    expect(
        subject.state,
        emitsInOrder(<dynamic>[
          predicate<EntitiesState>((state) => !state.isEmpty()),
        ]));
  }, timeout: const Timeout(Duration(seconds: 1)));

  test('assert that error state was emitted if getAll call throws an error',
      () async {
    final givenError = TestException();
    when(facade.getAll()).thenAnswer((_) async => throw TestException());
    final subject = createTestSubject()..refresh();
    await suspendMillis(5);
    expect(
        subject.state,
        emitsInOrder(<dynamic>[
          predicate<EntitiesState>((state) => state.error == givenError),
        ]));
  }, timeout: const Timeout(Duration(seconds: 1)));

  test(
      'assert that error was replaced by success state if facade returned '
      'a valid list after refresh', () async {
    final answers = <Future<List<Entity>> Function()>[
      () async => throw TestException(),
      () async => const <Entity>[],
    ];
    when(facade.getAll()).thenAnswer((_) => answers.removeAt(0)());
    final subject = createTestSubject()..refresh();
    expect(
        subject.state,
        emitsInOrder(<dynamic>[
          anything,
          predicate<EntitiesState>((state) {
            if (state.hasError) subject.refresh();
            return state.hasError;
          }),
          anything,
          predicate<EntitiesState>((state) => state.isSuccessful),
        ]));
  }, timeout: const Timeout(Duration(seconds: 1)));
}

class MockEntitiesFacade extends Mock implements EntitiesFacade {}

// ignore: avoid_implementing_value_types
class MockEntity extends Mock implements Entity {}
