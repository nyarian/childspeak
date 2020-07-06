import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/entity.dart';

class FlutterFirestoreEntityRepository implements EntityRepository {
  static const String _entitiesCollection = 'entity';
  static const String _localeMap = 'i18n';
  static const String _depictionField = 'image_url';

  final Firestore _firestore;

  FlutterFirestoreEntityRepository(this._firestore);

  @override
  Future<List<Entity>> getAll(String localeCode, {int limit = 200}) async {
    QuerySnapshot snapshot =
        await queryEntities(localeCode, limit).getDocuments();
    return snapshot.documents
        .map((DocumentSnapshot doc) => Entity(
            EntityId(doc.documentID),
            doc.data[_localeMap][localeCode] as String,
            Uri.parse(doc.data[_depictionField] as String)))
        .toList();
  }

  Query queryEntities(String localeCode, int limit) {
    final Query query = _localizedEntitiesQuery(localeCode);
    return limit == EntityRepository.noLimit ? query : query.limit(limit);
  }

  Query _localizedEntitiesQuery(String localeCode) => _firestore
      .collection(_entitiesCollection)
      .where('$_localeMap.$localeCode', isGreaterThan: '');

  @override
  Future<EntityId> add(String localeCode, Entity entity) async {
    DocumentReference result =
        await _firestore.collection(_entitiesCollection).add(<String, dynamic>{
      _localeMap: <String, String>{localeCode: entity.title},
      _depictionField: entity.depiction.toString(),
    });
    return EntityId(result.documentID);
  }
}
