import 'package:built_collection/built_collection.dart';
import 'package:domain/entity.dart';
import 'package:domain/src/entity/entity.dart';

abstract class EntityRepository {
  static const int noLimit = -1;

  Future<List<Entity>> getAll(String localeCode, {int limit = 200});

  Future<List<Entity>> getAllMatching(EntityCriteria criteria,
      {int limit = 200});

  Future<EntityId> add(String localeCode, Entity entity);
}

abstract class EntityCriteria {
  void addCriteria(EntityCriteriaVisitor visitor);
}

class CompositeEntityCriteria implements EntityCriteria {
  final BuiltList<EntityCriteria> _criteria;

  const CompositeEntityCriteria(this._criteria)
      : assert(_criteria != null, "Criteria list can't be null");

  @override
  void addCriteria(EntityCriteriaVisitor visitor) {
    for (final criteria in _criteria) {
      criteria.addCriteria(visitor);
    }
  }
}

class HasCategoryCriteria implements EntityCriteria {
  final Category _category;

  const HasCategoryCriteria(this._category)
      : assert(_category != null, "Category can't be null");

  @override
  void addCriteria(EntityCriteriaVisitor visitor) =>
      visitor.hasCategory(_category);
}

class LocaleCodeCriteria implements EntityCriteria {
  final String _localeCode;

  const LocaleCodeCriteria(this._localeCode)
      : assert(_localeCode != null, "Locale code can't be null");

  @override
  void addCriteria(EntityCriteriaVisitor visitor) =>
      visitor.ofLocale(_localeCode);
}

abstract class EntityCriteriaVisitor {
  void hasCategory(Category category);

  void ofLocale(String localeCode);
}
