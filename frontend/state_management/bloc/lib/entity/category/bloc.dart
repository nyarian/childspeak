import 'dart:async';

import 'package:bloc/state.dart';
import 'package:built_collection/built_collection.dart';
import 'package:domain/entity.dart';
import 'package:equatable/equatable.dart';
import 'package:estd/logger.dart';
import 'package:estd/resource.dart';
import 'package:rxdart/rxdart.dart';

class CategoriesBloc implements Resource {
  CategoriesBloc(
    this._repository,
    this._logger, [
    Duration eventThrottleTime = const Duration(milliseconds: 700),
  ]) {
    _stateSubject.add(CategoriesState._idle());
    _eventSC.stream
        .throttleTime(eventThrottleTime, trailing: true)
        .switchMap((event) => event._process(() => _stateSubject.value))
        .listen(_stateSubject.add);
  }

  final CategoryRepository _repository;
  final Logger _logger;

  final _eventSC = StreamController<_CategoriesEvent>();

  Sink<_CategoriesEvent> get eventSink => _eventSC.sink;

  final _stateSubject = BehaviorSubject<CategoriesState>();

  Stream<CategoriesState> get state => _stateSubject.stream;

  CategoriesState get currentState => _stateSubject.value;

  void onSearch(String query) =>
      _eventSC.add(_SearchCategoriesEvent(query, _logger, _repository));

  @override
  void close() {
    _eventSC.close();
    _stateSubject.close();
  }
}

enum _CategoriesStatus { idle, processing }

class SearchResult with EquatableMixin {
  final String query;
  final BuiltList<Category> categories;

  SearchResult._full(this.query, this.categories);

  @override
  List<Object> get props => <Object>[query, categories];

  @override
  bool get stringify => true;
}

class CategoriesState with ErrorProneState, EquatableMixin {
  final _CategoriesStatus _status;
  final SearchResult result;
  @override
  final Object error;

  CategoriesState._full(this._status, this.result, this.error)
      : assert(result == null || error == null,
            "Both result and error can't be non-null"),
        assert(_status != null || result != null || error != null,
            "All the properties can't be null at the same time"),
        assert(
            _status == null || (result == null && error == null),
            "Status and categories / error can't be non-null at the same time, "
            'but got status = $_status, error = $error, result = $result');

  CategoriesState._idle() : this._full(_CategoriesStatus.idle, null, null);

  CategoriesState._processing()
      : this._full(_CategoriesStatus.processing, null, null);

  CategoriesState._error(Object error) : this._full(null, null, error);

  CategoriesState._successful(String query, Iterable<Category> categories)
      : this._full(
            null, SearchResult._full(query, categories.toBuiltList()), null);

  bool get isIdle => _status == _CategoriesStatus.idle;

  bool get isProcessing => _status == _CategoriesStatus.processing;

  bool get isSuccessful => result != null;

  @override
  List<Object> get props => <Object>[_status, result, error];

  @override
  bool get stringify => true;
}

abstract class _CategoriesEvent {
  Stream<CategoriesState> _process(StateProvider provider);
}

class _SearchCategoriesEvent implements _CategoriesEvent {
  final String _query;
  final Logger _logger;
  final CategoryRepository _repository;

  _SearchCategoriesEvent(this._query, this._logger, this._repository);

  @override
  Stream<CategoriesState> _process(StateProvider provider) async* {
    yield CategoriesState._processing();
    try {
      final List<Category> categories =
          await _repository.getByTitlePart(_query);
      yield CategoriesState._successful(_query, categories);
    } on Object catch (e, st) {
      _logger.logError(e, st);
      yield CategoriesState._error(e);
    }
  }
}

typedef StateProvider = CategoriesState Function();
