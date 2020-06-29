import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/entity.dart';

class FlutterFirestoreEntityRepository implements EntityRepository {
  static const String _entitiesCollection = 'entity';
  static const String _localeDocument = 'locale';
  static const String _titleField = 'title';
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
            doc.data[_titleField] as String,
            Uri.parse(doc.data[_depictionField] as String)))
        .toList();
  }

  Query queryEntities(String localeCode, int limit) {
    final CollectionReference ref = _firestore
        .collection(_entitiesCollection)
        .document(_localeDocument)
        .collection(localeCode);
    return limit == EntityRepository.noLimit ? ref : ref.limit(limit);
  }
}
