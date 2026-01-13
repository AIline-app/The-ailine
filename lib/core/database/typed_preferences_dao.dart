import 'package:gghgggfsfs/core/database/shared_preferences_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences_entries.dart';

/// Интерфейс одного значения SharedPreferences определенного типа.
/// Например, bool или int, со значением, возможностью записать или удалить его.
abstract class PreferencesEntry<T> {
  T? get value;
  bool get exists;

  Future<bool> setValue(T value);
  Future<bool> remove();
}

/// Интерфейс с действиями (clear, reload и т.д.), которые можно совершить над SharedPreferences
abstract class ITypedPreferencesActions {
  Set<String> get keys;

  Future<bool> clear();

  Future<bool> commit();

  Future<void> reload();
}

/// Интерфейс для получения конкретных значений по ключу:
/// отдельный метод для bool, int, double, String и List<String>.
abstract class ITypedPreferencesEntries {
  PreferencesEntry<bool> boolEntry(String key);

  PreferencesEntry<int> intEntry(String key);

  PreferencesEntry<double> doubleEntry(String key);

  PreferencesEntry<String> stringEntry(String key);

  PreferencesEntry<List<String>> stringListEntry(String key);
}

/// Основной интерфейс, который объединяет действия и доступ к значениям.
abstract class ITypedPreferencesDao
    implements ITypedPreferencesActions, ITypedPreferencesEntries {}

class _TypedSharedPreferencesDaoDelegate extends SharedPreferencesDao {
  _TypedSharedPreferencesDaoDelegate(super.sharedPreferences, String name)
    : super(name: 'typed_$name');
}

/// Внутренний делегат, расширяющий функциональность SharedPreferences
/// с добавлением логирования и неймспейса.
abstract class TypedPreferencesDao implements ITypedPreferencesDao {
  final Map<String, PreferencesEntry> _entries = {};
  final ISharedPreferencesDao _delegate;

  TypedPreferencesDao(
    SharedPreferences sharedPreferences, {
    required String name,
  }) : _delegate = _TypedSharedPreferencesDaoDelegate(sharedPreferences, name);

  @override
  Set<String> get keys => _delegate.getKeys();

  @override
  Future<bool> clear() => _delegate.clear();

  @override
  @Deprecated('Deprecated for iOS')
  Future<bool> commit() => _delegate.commit();

  @override
  Future<void> reload() => _delegate.reload();

  @override
  PreferencesEntry<bool> boolEntry(String key) =>
      _entries.putIfAbsent(key, () => _BoolEntry(key, _delegate))
          as PreferencesEntry<bool>;

  @override
  PreferencesEntry<int> intEntry(String key) =>
      _entries.putIfAbsent(key, () => _IntEntry(key, _delegate))
          as PreferencesEntry<int>;

  @override
  PreferencesEntry<double> doubleEntry(String key) =>
      _entries.putIfAbsent(key, () => _DoubleEntry(key, _delegate))
          as PreferencesEntry<double>;

  @override
  PreferencesEntry<String> stringEntry(String key) =>
      _entries.putIfAbsent(key, () => _StringEntry(key, _delegate))
          as PreferencesEntry<String>;

  @override
  PreferencesEntry<List<String>> stringListEntry(String key) =>
      _entries.putIfAbsent(key, () => _StringListEntry(key, _delegate))
          as PreferencesEntry<List<String>>;
}
