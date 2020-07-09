import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/entity.dart';
import 'package:flutter_framework/domain/entity/factory.dart';

class FlutterFirestoreEntityRepository implements EntityRepository {
  static const String _entitiesCollection = 'entity';
  static const String _localeMap = 'i18n';

  final Firestore _firestore;
  final FirestoreEntityFactory _factory;

  FlutterFirestoreEntityRepository(this._firestore, this._factory);

  @override
  Future<List<Entity>> getAll(String localeCode, {int limit = 200}) async {
    QuerySnapshot snapshot =
        await queryEntities(localeCode, limit).getDocuments();
    return snapshot.documents
        .map((DocumentSnapshot doc) => _factory.reverse(doc, localeCode))
        .toList();
  }

  Query queryEntities(String localeCode, int limit) {
    final Query query = _firestore
        .collection(_entitiesCollection)
        .where('$_localeMap.$localeCode', isGreaterThan: '');
    return limit == EntityRepository.noLimit ? query : query.limit(limit);
  }

  @override
  Future<EntityId> add(String localeCode, Entity entity) async {
    DocumentReference result = await _firestore
        .collection(_entitiesCollection)
        .add(_factory.convert(entity, localeCode));
    return EntityId(result.documentID);
  }
}
