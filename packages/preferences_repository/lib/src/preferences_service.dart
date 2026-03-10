import 'dart:async';
import 'dart:convert';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared/shared.dart' show NoteListDensity, NoteViewMode;

import 'preferences.dart';
import 'preferences_storage.dart';

/// Loads, persists and streams [Preferences].
class PreferencesService {
  PreferencesService._(this._prefs, this._current);

  static const _key = 'app_preferences';

  final PreferencesStorage _prefs;
  final _controller = StreamController<Preferences>.broadcast();
  Preferences _current;

  static Future<PreferencesService> create({
    required List<String> supportedCodes,
  }) async {
    final prefs = PreferencesStorage();
    final settings = await _load(prefs, supportedCodes);
    return PreferencesService._(prefs, settings);
  }

  Stream<Preferences> get stream => _controller.stream;

  Preferences get current => _current;

  // Future<void> dispose() => _controller.close();

  Future<void> update(Preferences Function(Preferences) transform) async {
    _current = transform(_current);
    await _save(_prefs, _current);
    _controller.add(_current);
  }

  static Locale _resolveInitialLocale(List<String> supportedCodes) {
    final code = PlatformDispatcher.instance.locale.languageCode;
    return Locale(supportedCodes.contains(code) ? code : 'en');
  }

  static Future<Preferences> _load(
    PreferencesStorage prefs,
    List<String> supportedCodes,
  ) async {
    final json = await prefs.getString(_key);
    if (json == null)
      return Preferences(locale: _resolveInitialLocale(supportedCodes));
    try {
      final map = jsonDecode(json) as Map<String, Object?>;
      return Preferences(
        themeMode: ThemeMode.values.byName(
          map['themeMode'] as String? ?? 'system',
        ),
        locale: Locale(map['locale'] as String? ?? 'en'),
        noteViewMode: NoteViewMode.values.byName(
          map['noteViewMode'] as String? ?? 'grid',
        ),
        noteListDensity: NoteListDensity.values.byName(
          map['noteListDensity'] as String? ?? 'threeLines',
        ),
      );
    } catch (_) {
      return const Preferences();
    }
  }

  static Future<void> _save(PreferencesStorage prefs, Preferences s) async {
    final map = <String, Object?>{
      'themeMode': s.themeMode.name,
      'locale': s.locale.languageCode,
      'noteViewMode': s.noteViewMode.name,
      'noteListDensity': s.noteListDensity.name,
    };
    await prefs.setString(_key, jsonEncode(map));
  }
}
