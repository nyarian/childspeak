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
import 'package:tuple/tuple.dart';

class EntitiesBloc implements Resource {
  EntitiesBloc(this._facade, this._logger) {
    _eventSC.stream
        .asyncExpand((event) => event._process())
        .listen(_stateBS.add);
  }

  void refresh(String localeCode, Category category) {
    _eventSC.add(_RefreshEvent(
      localeCode,
      category,
      () => currentState,
      _facade,
      _logger,
    ));
  }

  @override
  void close() {
    _eventSC.close();
    _stateBS.close();
  }

  Stream<EntitiesState> get state => _stateBS.stream;

  EntitiesState get currentState => _stateBS.value;

  final StreamController<_EntitiesEvent> _eventSC =
      StreamController<_EntitiesEvent>();

  final BehaviorSubject<EntitiesState> _stateBS =
      BehaviorSubject<EntitiesState>();

  final EntitiesFacade _facade;

  final Logger _logger;
}

class EntitiesResult with EquatableMixin {
  final String localeCode;
  final Category category;
  final BuiltList<Entity> entities;

  EntitiesResult(this.localeCode, this.category, this.entities);

  @override
  List<Object> get props => <Object>[localeCode, category, entities];

  @override
  bool get stringify => true;
}

class EntitiesState with ErrorProneState, EquatableMixin {
  final EntitiesResult _result;
  @override
  final Object error;
  final bool isRetrievingEntities;

  String get localeCode => _result?.localeCode;

  Category get category => _result?.category;

  BuiltList<Entity> get entities => _result?.entities;

  EntitiesState._(this._result, this.error, {this.isRetrievingEntities});

  EntitiesState._success(
      String localeCode, Category category, List<Entity> entities)
      : this._(EntitiesResult(localeCode, category, entities.build()), null,
            isRetrievingEntities: false);

  EntitiesState._retrieving() : this._(null, null, isRetrievingEntities: true);

  EntitiesState.error(Object error)
      : this._(null, error, isRetrievingEntities: false);

  bool get isSuccessful => !hasError && !isRetrievingEntities;

  bool isEmpty() =>
      entities?.isEmpty ??
      (throw StateError('State is not successful, isEmpty call is illegal\n'));

  EntitiesState _copy({
    Optional<EntitiesResult> result,
    Optional<Object> error,
    Optional<bool> isRetrievingEntities,
  }) =>
      EntitiesState._(
        result == null ? _result : result.orElse(null),
        error == null ? this.error : error.orElse(null),
        isRetrievingEntities: isRetrievingEntities == null
            ? this.isRetrievingEntities
            : isRetrievingEntities.orElse(null),
      );

  @override
  List<Object> get props => <Object>[entities, error, isRetrievingEntities];

  @override
  bool get stringify => true;
}

// ignore: one_member_abstracts
abstract class _EntitiesEvent {
  Stream<EntitiesState> _process();
}

class _RefreshEvent implements _EntitiesEvent {
  final String _localeCode;
  final Category _category;
  final _EntitiesStateProvider _provider;
  final EntitiesFacade _facade;
  final Logger _logger;

  _RefreshEvent(
    this._localeCode,
    this._category,
    this._provider,
    this._facade,
    this._logger,
  ) : assert(_localeCode != null, "Locale code can't be null");

  @override
  Stream<EntitiesState> _process() async* {
    final currentState = _provider();
    if (currentState == null || !currentState.isRetrievingEntities) {
      yield retrievingState();
      try {
        final Tuple2<String, List<Entity>> result =
            await _facade.getAll(_localeCode, _category);
        yield EntitiesState._success(result.item1, _category, result.item2);
      } on Object catch (e, st) {
        _logger.logError(e, st);
        yield errorState(e);
      }
    }
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
