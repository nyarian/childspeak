import 'package:domain/entity.dart';
import 'package:tuple/tuple.dart';

class EntitiesFacade {
  final String _defaultLocale;
  final EntityRepository _repository;

  EntitiesFacade(this._defaultLocale, this._repository);

  Future<Tuple2<String, List<Entity>>> getAll(String localeCode) async {
    List<Entity> targetLocaleEntities = await _repository.getAll(localeCode);
    return targetLocaleEntities.isEmpty
        ? Tuple2<String, List<Entity>>(
            _defaultLocale, await _repository.getAll(_defaultLocale))
        : Tuple2<String, List<Entity>>(localeCode, targetLocaleEntities);
  }
}
