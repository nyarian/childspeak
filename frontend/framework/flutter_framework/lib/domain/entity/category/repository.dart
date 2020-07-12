import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:domain/entity.dart';
import 'package:flutter_framework/infrastructure/firestore/structure.dart';

class InMemoryCategoryRepository implements CategoryRepository {
  final BuiltList<String> _tags;

  InMemoryCategoryRepository(this._tags);

  @override
  Future<List<Category>> getByTitlePart(String prefix) async => _tags
      .where((tag) => tag.contains(prefix))
      .toSet()
      .map(Category.fromString)
      .toList();
}

class FirestoreCategoryRepositoryProxy implements CategoryRepository {
  final ChildSpeakFirestoreStructure _structure;
  final _CategoryRepositoryFactory _factory;
  Completer<CategoryRepository> _repositoryCompleter;

  FirestoreCategoryRepositoryProxy(
    this._structure,
    this._factory,
  );

  @override
  Future<List<Category>> getByTitlePart(String part) {
    final completer =
        _repositoryCompleter ?? _initializeCompletedAndUpdateWithFetchedTags();
    return completer.future.then((delegate) => delegate.getByTitlePart(part));
  }

  Completer<CategoryRepository> _initializeCompletedAndUpdateWithFetchedTags() {
    _repositoryCompleter = Completer<CategoryRepository>();
    _structure
        .entities()
        .crossdata()
        .fetchTags()
        .then(_factory)
        .then(_repositoryCompleter.complete)
        .catchError((dynamic e, [StackTrace st]) {
      _repositoryCompleter.completeError(e, st);
      _repositoryCompleter = null;
    });
    return _repositoryCompleter;
  }
}

typedef _CategoryRepositoryFactory = CategoryRepository Function(
  Iterable<String> tags,
);
