import 'package:bloc/entity/bloc.dart';
import 'package:bloc/entity/facade.dart';
import 'package:estd/ioc/service_locator.dart';
import 'package:estd/logger.dart';
import 'package:flutter_framework/domain/entity/repository.dart';
import 'package:flutter_framework/domain/entity/factory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EntitiesBlocFactory {

  static const String _fallbackLocale = 'en';

  factory EntitiesBlocFactory() => const EntitiesBlocFactory._();

  const EntitiesBlocFactory._();

  EntitiesBloc create(ServiceLocator locator) => EntitiesBloc(
    EntitiesFacade(
      _fallbackLocale,
      FlutterFirestoreEntityRepository(
        locator.get<Firestore>(),
        const FirestoreEntityFactory(),
      ),
    ),
    locator.get<Logger>(),
  );

}
