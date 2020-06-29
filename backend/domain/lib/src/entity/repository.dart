import 'package:domain/src/entity/entity.dart';

abstract class EntityRepository {

  static const int noLimit = -1;

  Future<List<Entity>> getAll(String localeCode, {int limit = 200});

  Future<EntityId> add(String localeCode, Entity entity);

}
