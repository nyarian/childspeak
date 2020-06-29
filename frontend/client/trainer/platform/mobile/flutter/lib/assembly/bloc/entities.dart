import 'package:bloc/entity/entity.dart';
import 'package:bloc/entity/facade.dart';
import 'package:estd/ioc/service_locator.dart';
import 'package:estd/logger.dart';
import 'package:flutter_framework/domain/entity/repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EntitiesBlocFactory {

  factory EntitiesBlocFactory() => const EntitiesBlocFactory._();

  const EntitiesBlocFactory._();

  EntitiesBloc create(ServiceLocator locator) => EntitiesBloc(
    EntitiesFacade(
      FlutterFirestoreEntityRepository(
        locator.get<Firestore>(),
      ),
    ),
    locator.get<Logger>(),
  );

}
