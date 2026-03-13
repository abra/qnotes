# preferences_service

Streams `Preferences` changes and provides them to the widget tree via `PreferencesScope`.
Persistence is handled by `preferences_repository`.

---

## What's included

| Class                | Description                                                     |
|----------------------|-----------------------------------------------------------------|
| `PreferencesService` | Loads from repository on startup, persists on update, streams changes |
| `PreferencesScope`   | InheritedWidget — provides current `Preferences` to the subtree |

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

```dart
PreferencesScope.update(context, (p) => p.copyWith(themeMode: ThemeMode.dark));
PreferencesScope.update(context, (p) => p.copyWith(locale: const Locale('ru')));
```

Changes are persisted immediately and streamed to all widgets that called `PreferencesScope.of(context)`.

---

## Wiring

`PreferencesService` is created in `composition.dart` and stored in `DependenciesContainer`.
`PreferencesScope` is placed in `RootContext` and wraps the whole widget tree.

```
DependenciesScope
  └─ PreferencesScope     ← StreamBuilder + InheritedWidget
       └─ MaterialContext ← reads theme/locale, passes to MaterialApp
            └─ your app
```
