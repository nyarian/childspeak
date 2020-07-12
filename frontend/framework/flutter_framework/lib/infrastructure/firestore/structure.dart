import 'package:cloud_firestore/cloud_firestore.dart';

class ChildSpeakFirestoreStructure {
  final Firestore _firestore;

  ChildSpeakFirestoreStructure(this._firestore);

  EntitiesCollection entities() => EntitiesCollection(_firestore);

}

class EntitiesCollection {
  final Firestore _firestore;

  EntitiesCollection(this._firestore);

  EntitiesCrossdataDocument crossdata() =>
      EntitiesCrossdataDocument(_firestore);
}

class EntitiesCrossdataDocument {
  final Firestore _firestore;

  EntitiesCrossdataDocument(this._firestore);

  Future<List<String>> fetchTags() async {
    final DocumentSnapshot document = await _firestore.collection('entity')
        .document('crossdata')
        .get();
    return (document.data['tags'] as List<dynamic>).cast<String>();
  }

}
