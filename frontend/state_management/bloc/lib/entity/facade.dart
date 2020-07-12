import 'package:domain/entity.dart';
import 'package:tuple/tuple.dart';
import 'package:built_collection/built_collection.dart';

class EntitiesFacade {
  final String _defaultLocale;
  final EntityRepository _repository;

  EntitiesFacade(this._defaultLocale, this._repository);

  Future<Tuple2<String, List<Entity>>> getAll(
      String localeCode, Category category) async {
    EntityCriteria criteria = _createCriteria(localeCode, category);
    List<Entity> targetLocaleEntities =
        await _repository.getAllMatching(criteria);
    return targetLocaleEntities.isEmpty
        ? Tuple2<String, List<Entity>>(
            _defaultLocale,
            await _repository
                .getAllMatching(_createCriteria(_defaultLocale, category)))
        : Tuple2<String, List<Entity>>(localeCode, targetLocaleEntities);
  }

  EntityCriteria _createCriteria(String localeCode, Category category) =>
      CompositeEntityCriteria(
        <EntityCriteria>[
          LocaleCodeCriteria(localeCode),
          if (category != null) HasCategoryCriteria(category),
        ].toBuiltList(),
      );
}
