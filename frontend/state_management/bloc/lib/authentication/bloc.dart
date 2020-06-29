import 'dart:async';

import 'package:bloc/authentication/facade.dart';
import 'package:bloc/state.dart';
import 'package:estd/logger.dart';
import 'package:estd/resource.dart';
import 'package:equatable/equatable.dart';
import 'package:optional/optional.dart';
import 'package:rxdart/rxdart.dart';

class AuthenticationBloc implements Resource {
  final BehaviorSubject<AuthenticationState> _stateSubject =
      BehaviorSubject<AuthenticationState>();

  Stream<AuthenticationState> get state => _stateSubject.stream;

  AuthenticationState get currentState => _stateSubject.value;

  final StreamController<_AuthenticationEvent> _eventSC =
      StreamController<_AuthenticationEvent>();

  final AuthenticationFacade _facade;
  final Logger _logger;

  AuthenticationBloc(this._facade, this._logger) {
    _stateSubject.add(AuthenticationState._initial());
    _eventSC.stream
        .flatMap((event) => event.process(() => currentState))
        .listen(_stateSubject.add);
    onAuthStateCheckEvent();
  }

  void onAuthStateCheckEvent() =>
      _eventSC.add(_CheckAuthenticationStatusEvent(_facade, _logger));

  void onAnonymousSignInEvent() =>
      _eventSC.add(_AnonymousSignInEvent(_facade, _logger));

  void onEmailPasswordSignInEvent(String email, String password) => _eventSC
      .add(_EmailPasswordSignInEvent(email, password, _facade, _logger));

  void onAuthenticationErrorProcessedEvent() =>
      _eventSC.add(const _ClearAuthenticationErrorEvent());

  @override
  void close() {
    _stateSubject.close();
    _eventSC.close();
  }
}

enum AuthenticationStatus { unknown, notAuthenticated, authenticated }

enum AuthenticationProcessStatus { idle, checking, authenticating }

class AuthenticationState with ErrorProneState, EquatableMixin {
  final AuthenticationStatus authStatus;
  final AuthenticationProcessStatus processStatus;
  @override
  final Object error;

  AuthenticationState._(this.authStatus, this.processStatus, this.error);

  AuthenticationState._initial()
      : this._(AuthenticationStatus.unknown, AuthenticationProcessStatus.idle,
            null);

  AuthenticationState _copy({
    Optional<AuthenticationStatus> authStatus,
    Optional<AuthenticationProcessStatus> processStatus,
    Optional<Object> error,
  }) =>
      AuthenticationState._(
        authStatus == null ? this.authStatus : authStatus.orElse(null),
        processStatus == null ? this.processStatus : processStatus.orElse(null),
        error == null ? this.error : error.orElse(null),
      );

  @override
  List<Object> get props => <Object>[authStatus, processStatus, error];

  @override
  bool get stringify => true;
}

abstract class _AuthenticationEvent {
  Stream<AuthenticationState> process(_StateProvider provider);
}

class _CheckAuthenticationStatusEvent implements _AuthenticationEvent {
  final AuthenticationFacade _facade;
  final Logger _logger;

  _CheckAuthenticationStatusEvent(this._facade, this._logger);

  @override
  Stream<AuthenticationState> process(_StateProvider provider) async* {
    final currentState = provider();
    if (currentState.processStatus == AuthenticationProcessStatus.idle) {
      yield _checkingState(currentState);
      yield await _checkStatus(provider);
    } else {
      _logger.logError(_NotEligibleForAuthStatusCheckException(
          message: 'Current state: $currentState'));
    }
  }

  AuthenticationState _checkingState(AuthenticationState currentState) =>
      currentState._copy(
          processStatus: AuthenticationProcessStatus.checking.toOptional);

  Future<AuthenticationState> _checkStatus(_StateProvider provider) async {
    try {
      bool isAuthenticated = await _facade.isAuthenticated();
      return provider()._copy(
        authStatus: deductAuthStatus(authenticated: isAuthenticated).toOptional,
        processStatus: AuthenticationProcessStatus.idle.toOptional,
      );
    } on Object catch (e, st) {
      _logger.logError(e, st);
      return provider()._copy(error: e.toOptional);
    }
  }

  AuthenticationStatus deductAuthStatus({bool authenticated}) => authenticated
      ? AuthenticationStatus.authenticated
      : AuthenticationStatus.notAuthenticated;
}

class _NotEligibleForAuthStatusCheckException
    with EquatableMixin
    implements Exception {
  final String message;
  final Object cause;

  _NotEligibleForAuthStatusCheckException({this.message, this.cause});

  @override
  List<Object> get props => <Object>[message, cause];

  @override
  bool get stringify => true;
}

class _AnonymousSignInEvent implements _AuthenticationEvent {
  final AuthenticationFacade _facade;
  final Logger _logger;

  _AnonymousSignInEvent(this._facade, this._logger);

  @override
  Stream<AuthenticationState> process(_StateProvider provider) async* {
    final currentState = provider();
    if (currentState.processStatus == AuthenticationProcessStatus.idle &&
        currentState.authStatus == AuthenticationStatus.notAuthenticated) {
      yield currentState._copy(
          processStatus: AuthenticationProcessStatus.authenticating.toOptional);
      yield await _authenticate(provider);
    } else {
      _logger.logError(_NotEligibleForAnonymousAuthException(
          message: 'Current state: $currentState'));
    }
  }

  Future<AuthenticationState> _authenticate(_StateProvider provider) async {
    try {
      await _facade.authenticateAnonymously();
      return provider()._copy(
        authStatus: AuthenticationStatus.authenticated.toOptional,
        processStatus: AuthenticationProcessStatus.idle.toOptional,
      );
    } on Object catch (e, st) {
      _logger.logError(e, st);
      return provider()._copy(error: e.toOptional);
    }
  }
}

class _EmailPasswordSignInEvent implements _AuthenticationEvent {
  final String _email;
  final String _password;
  final AuthenticationFacade _facade;
  final Logger _logger;

  _EmailPasswordSignInEvent(
      this._email, this._password, this._facade, this._logger);

  @override
  Stream<AuthenticationState> process(_StateProvider provider) async* {
    final currentState = provider();
    if (currentState.processStatus == AuthenticationProcessStatus.idle &&
        currentState.authStatus == AuthenticationStatus.notAuthenticated) {
      yield currentState._copy(
          processStatus: AuthenticationProcessStatus.authenticating.toOptional);
      yield await _authenticate(provider);
    } else {
      _logger.logError(_NotEligibleForAnonymousAuthException(
          message: 'Current state: $currentState'));
    }
  }

  Future<AuthenticationState> _authenticate(_StateProvider provider) async {
    try {
      await _facade.authenticateWithEmailAndPassword(
          email: _email, password: _password);
      return provider()._copy(
        authStatus: AuthenticationStatus.authenticated.toOptional,
        processStatus: AuthenticationProcessStatus.idle.toOptional,
      );
    } on Object catch (e, st) {
      _logger.logError(e, st);
      return provider()._copy(error: e.toOptional);
    }
  }
}

class _NotEligibleForAnonymousAuthException
    with EquatableMixin
    implements Exception {
  final String message;
  final Object cause;

  _NotEligibleForAnonymousAuthException({this.message, this.cause});

  @override
  List<Object> get props => <Object>[message, cause];

  @override
  bool get stringify => true;
}

class _ClearAuthenticationErrorEvent implements _AuthenticationEvent {
  const _ClearAuthenticationErrorEvent();

  @override
  Stream<AuthenticationState> process(_StateProvider provider) async* {
    final currentState = provider();
    if (currentState.hasError) {
      yield currentState._copy(
        error: const Optional.empty(),
        processStatus: AuthenticationProcessStatus.idle.toOptional,
      );
    }
  }
}

typedef _StateProvider = AuthenticationState Function();
