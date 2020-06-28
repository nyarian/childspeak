import 'package:domain/src/entity/entity.dart';

abstract class EntityRepository {

  static const int noLimit = -1;

  Future<List<Entity>> getAll({int limit = 200});

}
