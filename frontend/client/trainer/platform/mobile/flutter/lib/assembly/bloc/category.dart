import 'package:bloc/entity/category/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estd/ioc/service_locator.dart';
import 'package:estd/logger.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter_framework/domain/entity/category/repository.dart';
import 'package:flutter_framework/infrastructure/firestore/structure.dart';

class CategoriesBlocFactory {
  const CategoriesBlocFactory();

  CategoriesBloc create(ServiceLocator locator) => CategoriesBloc(
        FirestoreCategoryRepositoryProxy(
          ChildSpeakFirestoreStructure(
            locator.get<Firestore>(),
          ),
          (Iterable<String> tags) =>
              InMemoryCategoryRepository(tags.toBuiltList()),
        ),
        locator.get<Logger>(),
      );
}
