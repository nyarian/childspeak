import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/entity.dart';
import 'package:estd/type/lateinit.dart';
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
        await _queryEntities(localeCode, limit).getDocuments();
    return snapshot.documents
        .map((DocumentSnapshot doc) => _factory.reverse(doc, localeCode))
        .toList();
  }

  Query _queryEntities(String localeCode, int limit) {
    final Query query = _firestore
        .collection(_entitiesCollection)
        .where('$_localeMap.$localeCode', isGreaterThan: '');
    return limit == EntityRepository.noLimit ? query : query.limit(limit);
  }

  @override
  Future<List<Entity>> getAllMatching(EntityCriteria criteria,
      {int limit = 200}) async {
    final localeCode = _LocaleCodeCaptor(criteria).localeCode;
    final originalQuery = _queryEntities(localeCode, limit);
    final query = _FirestoreQueryBuilder(originalQuery, criteria).query;
    final result = await query.getDocuments();
    return result.documents
        .map((DocumentSnapshot doc) => _factory.reverse(doc, localeCode))
        .toList();
  }

  @override
  Future<EntityId> add(String localeCode, Entity entity) async {
    DocumentReference result = await _firestore
        .collection(_entitiesCollection)
        .add(_factory.convert(entity, localeCode));
    return EntityId(result.documentID);
  }
}

class _FirestoreQueryBuilder implements EntityCriteriaVisitor {
  Query query;

  _FirestoreQueryBuilder(this.query, EntityCriteria criteria)
      : assert(query != null, "Initial query can't be null") {
    criteria.addCriteria(this);
  }

  @override
  void hasCategory(Category category) {
    query = query.where('tags', arrayContains: category.title);
  }

  @override
  void ofLocale(String localeCode) {
    // No-op
  }
}

// TODO(nyarian): handle ValueAlreadySetError
class _LocaleCodeCaptor implements EntityCriteriaVisitor {
  final _localeCodeRef = ImmutableLateinit<String>.unset();

  String get localeCode => _localeCodeRef.value;

  _LocaleCodeCaptor(EntityCriteria criteria) {
    criteria.addCriteria(this);
  }

  @override
  void hasCategory(Category category) {
    // No-op
  }

  @override
  void ofLocale(String localeCode) => _localeCodeRef.value = localeCode;
}
