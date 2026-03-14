# preferences_service

Streams `Preferences` changes and provides them to the widget tree via `PreferencesScope`.
Persistence is handled by `preferences_repository`.

---

## What's included

| Class                | Description                                                           |
|----------------------|-----------------------------------------------------------------------|
| `PreferencesService` | Loads from repository on startup, persists on update, streams changes |
| `PreferencesScope`   | InheritedWidget — provides current `Preferences` to the subtree       |

The `Preferences` model lives in `preferences_repository`.

---

## Usage

### Read preferences

```dart
final prefs = PreferencesScope.of(context);

prefs.themeMode  // ThemeMode (light / dark / system)
prefs.locale     // Locale
```

### Update preferences

Updates go through `PreferencesCubit` (in the `preferences_menu` feature) or directly via
`PreferencesService`:

```dart
// Via PreferencesCubit (in PreferencesMenu):
context.read<PreferencesCubit>().update((p) => p.copyWith(themeMode: ThemeMode.dark));
context.read<PreferencesCubit>().update((p) => p.copyWith(locale: const Locale('ru')));

// Directly (outside feature widgets):
await preferencesService.update((p) => p.copyWith(themeMode: ThemeMode.dark));
```

Changes are persisted immediately and streamed to all listeners (`PreferencesScope`,
`NoteListBloc`, etc.).

---

## Wiring

`PreferencesService` is created in `composition.dart` and stored in
`DependenciesContainer`.
`PreferencesScope` is placed in `RootContext` and wraps the whole widget tree.

```
DependenciesScope
  └─ PreferencesScope     ← StreamBuilder + InheritedWidget
       └─ MaterialContext ← reads theme/locale, passes to MaterialApp
            └─ your app
```
