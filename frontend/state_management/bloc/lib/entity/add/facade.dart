import 'package:domain/entity.dart';

class EntityCrudFacade {
  final EntityRepository _repository;

  EntityCrudFacade(this._repository);

  Future<void> add(String localeCode, Entity entity) =>
      _repository.add(localeCode, entity);

}
