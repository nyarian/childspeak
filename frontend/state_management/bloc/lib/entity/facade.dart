import 'package:domain/entity.dart';

class EntitiesFacade {
  final EntityRepository _repository;

  EntitiesFacade(this._repository);

  Future<List<Entity>> getAll() => _repository.getAll();
}
