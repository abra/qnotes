import 'dart:ui' show Locale;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared/shared.dart' show NoteViewMode;

/// Stores user preferences: theme mode, locale and note view mode.
final class Preferences {
  const Preferences({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.noteViewMode = NoteViewMode.grid,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final NoteViewMode noteViewMode;

  Preferences copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    NoteViewMode? noteViewMode,
  }) => Preferences(
    themeMode: themeMode ?? this.themeMode,
    locale: locale ?? this.locale,
    noteViewMode: noteViewMode ?? this.noteViewMode,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Preferences &&
          themeMode == other.themeMode &&
          locale == other.locale &&
          noteViewMode == other.noteViewMode;

  @override
  int get hashCode => Object.hash(themeMode, locale, noteViewMode);
}
