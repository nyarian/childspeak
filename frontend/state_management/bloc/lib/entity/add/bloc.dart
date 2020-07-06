import 'dart:async';

import 'package:bloc/entity/add/facade.dart';
import 'package:bloc/state.dart';
import 'package:domain/entity.dart';
import 'package:equatable/equatable.dart';
import 'package:estd/logger.dart';
import 'package:estd/resource.dart';
import 'package:meta/meta.dart';
import 'package:optional/optional.dart';
import 'package:rxdart/rxdart.dart';

class EntityCrudBloc implements Resource {
  final BehaviorSubject<EntityCrudState> _stateSubject =
      BehaviorSubject<EntityCrudState>();

  final StreamController<_EntityCrudEvent> _eventSC =
      StreamController<_EntityCrudEvent>();

  Stream<EntityCrudState> get state => _stateSubject.stream;

  EntityCrudState get currentState => _stateSubject.value;

  final EntityCrudFacade _facade;
  final Logger _logger;

  EntityCrudBloc(this._facade, this._logger) {
    _stateSubject.add(EntityCrudState._idle());
    _eventSC.stream
        // TODO(nyarian): experiment with concatMap to serialize processing
        .flatMap((value) => value.process(() => currentState))
        .listen(_stateSubject.add);
  }

  void onCreateEntityEvent({
    @required String localeCode,
    @required String title,
    @required String depictionUrl,
  }) =>
      _eventSC.add(_CreateEntityEvent(
        _facade,
        _logger,
        localeCode: localeCode,
        title: title,
        depictionUrl: depictionUrl,
      ));

  @override
  void close() {
    _stateSubject.close();
    _eventSC.close();
  }

  void onErrorProcessedEvent() => _eventSC.add(const _ResetSuccessStateEvent());

  void onSuccessProcessedEvent() =>
      _eventSC.add(const _ResetSuccessStateEvent());
}

enum CrudOperation { create }

enum OperationStatus { idle, running, success }

class EntityCrudState with ErrorProneState, EquatableMixin {
  final CrudOperation operation;
  final OperationStatus status;
  @override
  final Object error;

  EntityCrudState._(this.operation, this.status, this.error);

  EntityCrudState._idle() : this._(null, OperationStatus.idle, null);

  EntityCrudState._running(CrudOperation operation)
      : this._(operation, OperationStatus.running, null);

  EntityCrudState _copy({
    Optional<CrudOperation> operation,
    Optional<OperationStatus> status,
    Optional<Object> error,
  }) =>
      EntityCrudState._(
        operation == null ? this.operation : operation.orElse(null),
        status == null ? this.status : status.orElse(null),
        error == null ? this.error : error.orElse(null),
      );

  @override
  List<Object> get props => <Object>[operation, status, error];

  @override
  bool get stringify => true;
}

abstract class _EntityCrudEvent {
  Stream<EntityCrudState> process(_StateProvider provider);
}

class _CreateEntityEvent implements _EntityCrudEvent {
  final String localeCode;
  final String title;
  final String depictionUrl;
  final EntityCrudFacade _facade;
  final Logger _logger;

  _CreateEntityEvent(
    this._facade,
    this._logger, {
    @required this.localeCode,
    @required this.title,
    @required this.depictionUrl,
  });

  @override
  Stream<EntityCrudState> process(_StateProvider provider) async* {
    final currentState = provider();
    if (currentState.status == OperationStatus.idle && !currentState.hasError) {
      yield EntityCrudState._running(CrudOperation.create);
      yield await _createEntity(provider);
    } else {
      _logger.logError('Create operation requested whereas current state is '
          '$currentState');
    }
  }

  Future<EntityCrudState> _createEntity(_StateProvider provider) async {
    try {
      await _facade.add(
          localeCode, Entity(null, title, Uri.parse(depictionUrl)));
      return provider()._copy(status: OperationStatus.success.toOptional);
    } on Object catch (e, st) {
      _logger.logError(e, st);
      return provider()._copy(
        status: const Optional<OperationStatus>.empty(),
        error: e.toOptional,
      );
    }
  }
}

class _ResetSuccessStateEvent implements _EntityCrudEvent {
  const _ResetSuccessStateEvent();

  @override
  Stream<EntityCrudState> process(_StateProvider provider) async* {
    if (provider().status == OperationStatus.success) {
      yield EntityCrudState._idle();
    }
  }
}

typedef _StateProvider = EntityCrudState Function();
