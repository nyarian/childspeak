import 'dart:async';

import 'package:flutter_framework/domain/entity/category/repository.dart';
import 'package:flutter_framework/infrastructure/firestore/structure.dart';
import 'package:domain/entity.dart';
import 'package:matcher/matcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test_estd/test_estd.dart';

void main() {
  final crossDataMock = MockEntitiesCrossdataDocument();
  final entitiesCollectionMock = MockEntitiesCollection();
  final structureMock = MockChildSpeakFirestoreStructure();
  final delegateRepositoryMock = MockCategoryRepository();

  setUp(() {
    when(structureMock.entities()).thenReturn(entitiesCollectionMock);
    when(entitiesCollectionMock.crossdata()).thenReturn(crossDataMock);
  });

  tearDown(() {
    reset(structureMock);
    reset(entitiesCollectionMock);
    reset(crossDataMock);
    reset(delegateRepositoryMock);
  });

  FirestoreCategoryRepositoryProxy createTestSubject(
          [CategoryRepository Function(Iterable<String> tags) factory]) =>
      FirestoreCategoryRepositoryProxy(
          structureMock, factory ?? (_) => delegateRepositoryMock);

  test(
    'assert that the caller received the exception if database gateway has '
    'thrown one while retrieving tags',
    () async {
      final givenException = TestException();
      when(crossDataMock.fetchTags()).thenAnswer(
          (realInvocation) => Future<List<String>>.error(givenException));
      expect(
        createTestSubject().getByTitlePart('pref'),
        throwsA(const TypeMatcher<TestException>()),
      );
    },
    timeout: const Timeout(Duration(seconds: 1)),
  );

  test(
    'assert that the caller received the exception if delegate repository has '
    'thrown one while retrieving categories',
    () async {
      final givenException = TestException();
      const givenTags = <String>['one', 'two'];
      when(crossDataMock.fetchTags()).thenAnswer(
          (realInvocation) => Future<List<String>>.value(givenTags));
      when(delegateRepositoryMock.getByTitlePart(any)).thenAnswer(
          (realInvocation) => Future<List<Category>>.error(givenException));
      expect(
        createTestSubject().getByTitlePart('pref'),
        throwsA(const TypeMatcher<TestException>()),
      );
    },
    timeout: const Timeout(Duration(seconds: 1)),
  );

  test(
    'assert that two callers received the same exception if they both '
    'subscribed before the exception was thrown from the gateway',
    () async {
      final tagsCompleter = Completer<List<String>>();
      final givenException = TestException();
      when(crossDataMock.fetchTags())
          .thenAnswer((realInvocation) => tagsCompleter.future);
      final FirestoreCategoryRepositoryProxy proxy = createTestSubject();
      expect(
        proxy.getByTitlePart('pref'),
        throwsA(const TypeMatcher<TestException>()),
      );
      expect(
        proxy.getByTitlePart('pref'),
        throwsA(const TypeMatcher<TestException>()),
      );
      await reschedule();
      tagsCompleter.completeError(givenException);
    },
    timeout: const Timeout(Duration(seconds: 1)),
  );

  test(
    'assert that two callers received the same exception if they both '
    'subscribed before the exception was thrown from the repository',
    () async {
      final tagsCompleter = Completer<List<String>>();
      const givenTags = <String>['one', 'two'];
      final givenCategories = <Category>[
        const Category('one'),
        const Category('two')
      ];
      when(crossDataMock.fetchTags())
          .thenAnswer((realInvocation) => tagsCompleter.future);
      when(delegateRepositoryMock.getByTitlePart(any))
          .thenAnswer((realInvocation) => givenCategories.asFuture());
      final proxy = createTestSubject();
      expect(proxy.getByTitlePart('pref'), completion(givenCategories));
      expect(proxy.getByTitlePart('pref'), completion(givenCategories));
      await reschedule();
      tagsCompleter.complete(givenTags);
    },
    timeout: const Timeout(Duration(seconds: 1)),
  );

  test(
    'assert that first caller received an error and second - a valid '
    'categories list, if gateway answers were corresponding',
    () async {
      final errorCompleter = Completer<List<String>>();
      final tagsCompleter = Completer<List<String>>();
      final givenCategories = <Category>[
        const Category('one'),
        const Category('two')
      ];
      final tagsAnswers = <Future<List<String>>>[
        errorCompleter.future,
        tagsCompleter.future,
      ];
      when(crossDataMock.fetchTags())
          .thenAnswer((_) => tagsAnswers.removeAt(0));
      when(delegateRepositoryMock.getByTitlePart(any))
          .thenAnswer((realInvocation) => givenCategories.asFuture());
      final FirestoreCategoryRepositoryProxy proxy = createTestSubject();
      expect(
        proxy.getByTitlePart('pref'),
        throwsA(const TypeMatcher<TestException>()),
      );
      errorCompleter.completeError(TestException());
      await reschedule();
      expect(proxy.getByTitlePart('pref'), completion(givenCategories));
      tagsCompleter.complete(<String>['one', 'two']);
      await reschedule();
    },
    timeout: const Timeout(Duration(seconds: 1)),
  );

  test(
    'assert that tags were only fetched twice if for 3 calls where first '
    'fetch gave an error',
    () async {
      final givenCategories = <Category>[
        const Category('one'),
        const Category('two')
      ];
      final tagsAnswers = <Future<List<String>> Function()>[
        () => Future<List<String>>.error(TestException()),
        () => Future<List<String>>.value(<String>['one', 'two']),
        () => Future<List<String>>.error(const UnexpectedException()),
      ];
      when(crossDataMock.fetchTags())
          .thenAnswer((_) => tagsAnswers.removeAt(0)());
      when(delegateRepositoryMock.getByTitlePart(any))
          .thenAnswer((realInvocation) => givenCategories.asFuture());
      FirestoreCategoryRepositoryProxy proxy = createTestSubject();
      await expectLater(proxy.getByTitlePart('pref'), throwsA(anything));
      await expectLater(proxy.getByTitlePart('pref'), completes);
      await expectLater(proxy.getByTitlePart('pref'), completes);
      verify(crossDataMock.fetchTags()).called(2);
    },
    timeout: const Timeout(Duration(seconds: 5)),
  );

  test(
    'assert that categories were requested as much times as client calls were '
    'made to the proxy',
    () async {
      when(crossDataMock.fetchTags())
          .thenAnswer((_) => <String>['one', 'two'].asFuture());
      when(delegateRepositoryMock.getByTitlePart(any)).thenAnswer((_) =>
          <Category>[const Category('one'), const Category('two')].asFuture());
      FirestoreCategoryRepositoryProxy proxy = createTestSubject();
      await expectLater(proxy.getByTitlePart('pref'), completes);
      await expectLater(proxy.getByTitlePart('pref'), completes);
      await expectLater(proxy.getByTitlePart('pref'), completes);
      verify(delegateRepositoryMock.getByTitlePart(any)).called(3);
    },
    timeout: const Timeout(Duration(seconds: 5)),
  );
}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockChildSpeakFirestoreStructure extends Mock
    implements ChildSpeakFirestoreStructure {}

class MockEntitiesCollection extends Mock implements EntitiesCollection {}

class MockEntitiesCrossdataDocument extends Mock
    implements EntitiesCrossdataDocument {}
