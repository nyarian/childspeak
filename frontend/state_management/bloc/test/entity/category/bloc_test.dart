import 'package:mockito/mockito.dart';
import 'package:domain/entity.dart';
import 'package:estd/logger.dart';
import 'package:bloc/entity/category/bloc.dart';
import 'package:test/test.dart';
import 'package:test_estd/test_estd.dart';
import 'package:built_collection/built_collection.dart';

void main() {
  final mockRepository = MockCategoryRepository();
  final mockLogger = MockLogger();

  tearDown(() {
    reset(mockRepository);
    reset(mockLogger);
  });

  CategoriesBloc createTestSubject(
          [Duration throttleTime = const Duration(milliseconds: 5)]) =>
      CategoriesBloc(mockRepository, mockLogger, throttleTime);

  test(
    'assert that initial state is idle',
    () {
      expect(
        createTestSubject().state,
        emitsInOrder(
          <dynamic>[
            predicate<CategoriesState>((state) => state.isIdle),
          ],
        ),
      );
    },
    timeout: const Timeout(Duration(seconds: 1)),
  );

  test(
    'assert that state is updated to processing on query event dispatch',
    () async {
      final subject = createTestSubject()..onSearch('asdqwqe');
      expect(
        subject.state,
        emitsInOrder(
          <dynamic>[
            anything,
            predicate<CategoriesState>((state) => state.isProcessing),
          ],
        ),
      );
    },
    timeout: const Timeout(Duration(seconds: 1)),
  );

  test(
    'assert that successful state is emitted if repository has returned a list',
    () async {
      const givenQuery = 'asdqwqe';
      final givenCategories = <Category>[Category('asdasd'), Category('asdsa')];
      when(mockRepository.getByTitlePart(any))
          .thenAnswer((_) => givenCategories.asFuture());
      final subject = createTestSubject()..onSearch(givenQuery);
      await reschedule(times: 5);
      expect(
        subject.state,
        emitsInOrder(
          <dynamic>[
            predicate<CategoriesState>((state) =>
                state.isSuccessful &&
                state.result.query == givenQuery &&
                state.result.categories == givenCategories.toBuiltList()),
          ],
        ),
      );
    },
    timeout: const Timeout(Duration(seconds: 1)),
  );

  test(
    'assert that error state is emitted if repository has thrown an error',
    () async {
      when(mockRepository.getByTitlePart(any))
          .thenAnswer((_) async => throw TestException());
      final subject = createTestSubject()..onSearch('asdqwqe');
      await reschedule(times: 5);
      expect(
        subject.state,
        emitsInOrder(
          <dynamic>[
            predicate<CategoriesState>(
                (state) => state.hasError && state.error == TestException()),
          ],
        ),
      );
    },
    timeout: const Timeout(Duration(seconds: 1)),
  );

  test(
    'assert that only last event is handled if batch of events was submitted',
    () async {
      when(mockRepository.getByTitlePart(any))
          .thenAnswer((_) async => throw TestException());
      final subject = createTestSubject()
        ..onSearch('asdqwqe')
        ..onSearch('qwe')
        ..onSearch('asd');
      CategoriesState capturedState;
      await expectLater(
        subject.state,
        emitsInOrder(
          <dynamic>[
            anything,
            anything,
            predicate<CategoriesState>((state) {
              capturedState = state;
              return true;
            }),
          ],
        ),
      );
      await suspendMillis(25);
      expect(
          subject.state,
          emitsInOrder(<dynamic>[
            predicate<CategoriesState>(
                (state) => identical(state, capturedState)),
          ]));
    },
    timeout: const Timeout(Duration(seconds: 1)),
  );
}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockLogger extends Mock implements Logger {}
