class ImmutableLateinit<T> {
  T _value;
  bool _isSet;

  ImmutableLateinit.unset() : _isSet = false;

  ImmutableLateinit.set(T value)
      : _value = value,
        _isSet = true;

  set value(T value) {
    if (_isSet) throw ValueAlreadySetError.ofValue(_value, value);
    _isSet = true;
    _value = value;
  }

  T get value {
    if (!_isSet) throw ValueIsNotInitializedError();
    return _value;
  }
}

class ValueAlreadySetError extends StateError {
  ValueAlreadySetError.ofValue(Object setValue, Object newValue)
      : super('Value already set\nExisting value: $setValue\nNew value: '
            '$newValue');
}

class ValueIsNotInitializedError extends StateError {
  ValueIsNotInitializedError() : super('Value is not yet initialized');
}
