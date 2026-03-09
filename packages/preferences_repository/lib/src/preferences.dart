import 'dart:ui' show Locale;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared/shared.dart' show NoteListDensity, NoteViewMode;

/// Stores user preferences: theme mode, locale and note view mode.
final class Preferences {
  const Preferences({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.noteViewMode = NoteViewMode.grid,
    this.noteListDensity = NoteListDensity.threeLines,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final NoteViewMode noteViewMode;
  final NoteListDensity noteListDensity;

  Preferences copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    NoteViewMode? noteViewMode,
    NoteListDensity? noteListDensity,
  }) => Preferences(
    themeMode: themeMode ?? this.themeMode,
    locale: locale ?? this.locale,
    noteViewMode: noteViewMode ?? this.noteViewMode,
    noteListDensity: noteListDensity ?? this.noteListDensity,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Preferences &&
          themeMode == other.themeMode &&
          locale == other.locale &&
          noteViewMode == other.noteViewMode &&
          noteListDensity == other.noteListDensity;

  @override
  int get hashCode =>
      Object.hash(themeMode, locale, noteViewMode, noteListDensity);
}
