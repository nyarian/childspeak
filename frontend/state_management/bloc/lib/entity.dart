import 'dart:async';

import 'package:domain/entity.dart';
import 'package:estd/resource.dart';
import 'package:built_collection/built_collection.dart';

class EntitiesBloc implements Resource {
  final StreamController<BuiltList<Entity>> _sc =
      StreamController<BuiltList<Entity>>();

  Stream<BuiltList<Entity>> get stream => _sc.stream;



  @override
  void close() {
    _sc.close();
  }
}
