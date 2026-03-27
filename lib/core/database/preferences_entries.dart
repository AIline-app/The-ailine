part of 'typed_preferences_dao.dart';

/// Абстрактный базовый класс для любого типа (bool, int и т.д.).
/// Делегирует работу к _delegate — объекту, реализующему чтение/запись по ключу.
abstract class _BasePreferencesEntry<T> implements PreferencesEntry<T> {
  final String _key;
  final ISharedPreferencesDao _delegate;

  _BasePreferencesEntry._(String key, this._delegate)
      : _key = _delegate.key(key);

  @override
  bool get exists => _delegate.containsKey(_key);

  @override
  Future<bool> remove() => _delegate.remove(_key);
}

/// Класс доступа к bool-переменной в SharedPreferences.
class _BoolEntry extends _BasePreferencesEntry<bool> {
  _BoolEntry(super.key, super.delegate)
      : super._();

  @override
  bool? get value => _delegate.getBool(_key);

  @override
  Future<bool> setValue(bool value) => _delegate.setBool(_key, value);
}


/// 📌 Аналогично реализованы _IntEntry, _DoubleEntry, _StringEntry, _StringListEntry — просто меняется тип.
class _IntEntry extends _BasePreferencesEntry<int> {
  _IntEntry(super.key, super.delegate)
      : super._();

  @override
  int? get value => _delegate.getInt(_key);

  @override
  Future<bool> setValue(int value) => _delegate.setInt(_key, value);
}

class _DoubleEntry extends _BasePreferencesEntry<double> {
  _DoubleEntry(super.key, super.delegate)
      : super._();

  @override
  double? get value => _delegate.getDouble(_key);

  @override
  Future<bool> setValue(double value) => _delegate.setDouble(_key, value);
}

class _StringEntry extends _BasePreferencesEntry<String> {
  _StringEntry(super.key, super.delegate)
      : super._();

  @override
  String? get value => _delegate.getString(_key);

  @override
  Future<bool> setValue(String value) => _delegate.setString(_key, value);
}

class _StringListEntry extends _BasePreferencesEntry<List<String>> {
  _StringListEntry(super.key, super.delegate)
      : super._();

  @override
  List<String>? get value => _delegate.getStringList(_key);

  @override
  Future<bool> setValue(List<String> value) =>
      _delegate.setStringList(_key, value);
}
