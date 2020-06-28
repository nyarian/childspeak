import 'dart:async';

import 'package:bloc/entity/facade.dart';
import 'package:bloc/state.dart';
import 'package:domain/entity.dart';
import 'package:equatable/equatable.dart';
import 'package:estd/logger.dart';
import 'package:estd/resource.dart';
import 'package:built_collection/built_collection.dart';
import 'package:optional/optional.dart';
import 'package:rxdart/subjects.dart';

class EntitiesBloc implements Resource {
  final StreamController<_EntitiesEvent> _eventSC =
      StreamController<_EntitiesEvent>();

  final BehaviorSubject<EntitiesState> _stateBS =
      BehaviorSubject<EntitiesState>();

  Stream<EntitiesState> get state => _stateBS.stream;

  final EntitiesFacade _facade;
  final Logger _logger;

  EntitiesBloc(this._facade, this._logger) {
    _eventSC.stream.asyncExpand(_EntitiesEvent._sProcess).listen(_stateBS.add);
  }

  void refresh() {
    _eventSC.add(_RefreshEvent(() => _stateBS.value, _facade, _logger));
  }

  @override
  void close() {
    _eventSC.close();
    _stateBS.close();
  }
}

class EntitiesState with ErrorProneState, EquatableMixin {
  final BuiltList<Entity> entities;
  @override
  final Object error;
  final bool isRetrievingEntities;

  EntitiesState._(this.entities, this.error, {this.isRetrievingEntities});

  EntitiesState._success(List<Entity> entities)
      : this._(entities.build(), null, isRetrievingEntities: false);

  EntitiesState._retrieving()
      : this._(BuiltList<Entity>(), null, isRetrievingEntities: true);

  EntitiesState.error(Object error)
      : this._(null, error, isRetrievingEntities: false);

  bool get isSuccessful => !hasError && !isRetrievingEntities;

  bool isEmpty() =>
      entities?.isEmpty ??
      (throw StateError('State is not successful, isEmpty call is illegal\n'));

  EntitiesState _copy({
    Optional<BuiltList<Entity>> entities,
    Optional<Object> error,
    Optional<bool> isRetrievingEntities,
  }) =>
      EntitiesState._(
        entities == null ? this.entities : entities.orElse(null),
        error == null ? this.error : error.orElse(null),
        isRetrievingEntities: isRetrievingEntities == null
            ? this.isRetrievingEntities
            : isRetrievingEntities.orElse(null),
      );

  EntitiesState _append(Iterable<Entity> entities) => EntitiesState._(
        <Entity>[...this.entities, ...entities].toBuiltList(),
        error,
        isRetrievingEntities: false,
      );

  @override
  List<Object> get props => <Object>[entities, error, isRetrievingEntities];

  @override
  bool get stringify => true;
}

// ignore: one_member_abstracts
abstract class _EntitiesEvent {
  Stream<EntitiesState> _process();

  static Stream<EntitiesState> _sProcess(_EntitiesEvent event) =>
      event._process();
}

class _RefreshEvent implements _EntitiesEvent {
  final _EntitiesStateProvider _provider;
  final EntitiesFacade _facade;
  final Logger _logger;

  _RefreshEvent(this._provider, this._facade, this._logger);

  @override
  Stream<EntitiesState> _process() async* {
    final currentState = _provider();
    if (currentState == null || !currentState.isRetrievingEntities) {
      yield retrievingState();
      try {
        final entities = await _facade.getAll();
        yield successState(entities);
      } on Object catch (e, st) {
        _logger.logError(e, st);
        yield errorState(e);
      }
    }
  }

  EntitiesState successState(List<Entity> entities) {
    final currentState = _provider();
    return currentState == null
        ? EntitiesState._success(entities)
        : currentState._append(entities);
  }

  EntitiesState retrievingState() {
    final currentState = _provider();
    return currentState == null
        ? EntitiesState._retrieving()
        : _provider()._copy(
            error: const Optional.empty(),
            isRetrievingEntities: Optional.of(true),
          );
  }

  EntitiesState errorState(Object e) {
    final currentState = _provider();
    return currentState == null
        ? EntitiesState.error(e)
        : currentState._copy(
            isRetrievingEntities: Optional.of(false), error: Optional.of(e));
  }
}

typedef _EntitiesStateProvider = EntitiesState Function();
