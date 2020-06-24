import 'package:domain/src/entity/entity.dart';

abstract class EntityRepository {

  Future<List<EntityId>> getAllIds({int limit = 200});

  Future<List<Entity>> getByIds(List<EntityId> ids);

}
