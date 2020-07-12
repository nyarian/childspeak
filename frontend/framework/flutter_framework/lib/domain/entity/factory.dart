import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/entity.dart';

class FirestoreEntityFactory {
  static const String _localeMap = 'i18n';
  static const String _depictionField = 'image_url';

  const FirestoreEntityFactory();

  Map<String, dynamic> convert(Entity entity, String localeCode) =>
      <String, dynamic>{
        _localeMap: <String, String>{localeCode: entity.title},
        _depictionField: entity.depiction.toString(),
      };

  Entity reverse(DocumentSnapshot doc, String localeCode) => Entity(
        EntityId(doc.documentID),
        doc.data[_localeMap][localeCode] as String,
        Uri.parse(doc.data[_depictionField] as String),
        BuiltList<Category>(),
      );
}
