import 'package:bloc/entity/add/bloc.dart';
import 'package:bloc/entity/add/facade.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estd/ioc/service_locator.dart';
import 'package:estd/logger.dart';
import 'package:flutter_framework/domain/entity/repository.dart';
import 'package:flutter_framework/domain/entity/factory.dart';

class EntityCrudBlocFactory {
  factory EntityCrudBlocFactory() => const EntityCrudBlocFactory._();

  const EntityCrudBlocFactory._();

  EntityCrudBloc create(ServiceLocator locator) => EntityCrudBloc(
        EntityCrudFacade(
          FlutterFirestoreEntityRepository(
            locator.get<Firestore>(),
            const FirestoreEntityFactory(),
          ),
        ),
        locator.get<Logger>(),
      );
}
