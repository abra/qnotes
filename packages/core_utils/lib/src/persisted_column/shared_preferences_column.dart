import 'dart:convert';

import 'package:core_utils/src/persisted_column/persisted_column.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base class for a single typed entry in [SharedPreferencesAsync].
abstract base class SharedPreferencesColumn<T extends Object>
    extends PersistedColumn<T> {
  const SharedPreferencesColumn({
    required this.sharedPreferences,
    required this.key,
  });

  final SharedPreferencesAsync sharedPreferences;
  final String key;

  @override
  Future<void> remove() => sharedPreferences.remove(key);
}

/// [int] column.
final class SharedPreferencesColumnInteger
    extends SharedPreferencesColumn<int> {
  const SharedPreferencesColumnInteger({
    required super.sharedPreferences,
    required super.key,
  });

  @override
  Future<int?> read() => sharedPreferences.getInt(key);

  @override
  Future<void> set(int value) => sharedPreferences.setInt(key, value);
}

/// [String] column.
final class SharedPreferencesColumnString
    extends SharedPreferencesColumn<String> {
  const SharedPreferencesColumnString({
    required super.sharedPreferences,
    required super.key,
  });

  @override
  Future<String?> read() => sharedPreferences.getString(key);

  @override
  Future<void> set(String value) => sharedPreferences.setString(key, value);
}

/// [bool] column.
final class SharedPreferencesColumnBoolean
    extends SharedPreferencesColumn<bool> {
  const SharedPreferencesColumnBoolean({
    required super.sharedPreferences,
    required super.key,
  });

  @override
  Future<bool?> read() => sharedPreferences.getBool(key);

  @override
  Future<void> set(bool value) => sharedPreferences.setBool(key, value);
}

/// [double] column.
final class SharedPreferencesColumnDouble
    extends SharedPreferencesColumn<double> {
  const SharedPreferencesColumnDouble({
    required super.sharedPreferences,
    required super.key,
  });

  @override
  Future<double?> read() => sharedPreferences.getDouble(key);

  @override
  Future<void> set(double value) => sharedPreferences.setDouble(key, value);
}

/// [List<String>] column.
final class SharedPreferencesColumnStringList
    extends SharedPreferencesColumn<List<String>> {
  const SharedPreferencesColumnStringList({
    required super.sharedPreferences,
    required super.key,
  });

  @override
  Future<List<String>?> read() => sharedPreferences.getStringList(key);

  @override
  Future<void> set(List<String> value) =>
      sharedPreferences.setStringList(key, value);
}

/// [Map<String, Object?>] column stored as JSON string.
final class SharedPreferencesColumnJson
    extends SharedPreferencesColumn<Map<String, Object?>> {
  const SharedPreferencesColumnJson({
    required super.sharedPreferences,
    required super.key,
  });

  @override
  Future<Map<String, Object?>?> read() async {
    final jsonString = await sharedPreferences.getString(key);
    if (jsonString == null) return null;

    final decoded = jsonDecode(jsonString);
    if (decoded is Map<String, Object?>) return decoded;

    throw const FormatException('Stored value is not a JSON object');
  }

  @override
  Future<void> set(Map<String, Object?> value) =>
      sharedPreferences.setString(key, jsonEncode(value));
}
