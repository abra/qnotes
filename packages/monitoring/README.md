# monitoring

Пакет для логирования, отчётов об ошибках и аналитики.

Содержит готовую инфраструктуру (Logger, интерфейсы) и заглушки (Noop*),
которые нужно заменить на реальные реализации перед релизом.

---

## Что внутри

| Класс | Тип | Статус |
|---|---|---|
| `Logger` | base class | Готов — работает через наблюдателей (`LogObserver`) |
| `LogLevel` | enum | Готов |
| `LogObserver` | mixin | Готов — реализуй чтобы получать лог-сообщения |
| `LogMessage` | data class | Готов |
| `PrintingLogObserver` | concrete | Готов — печатает в консоль через `debugPrint` |
| `ErrorReporterLogObserver` | concrete | Готов — пробрасывает ошибки из Logger в ErrorReportingService |
| `ErrorReportingService` | interface | Реализуй для продакшна |
| `NoopErrorReporter` | concrete | Заглушка — ничего не делает, безопасна для разработки |
| `AnalyticsEvent` | abstract base class | Готов — расширяй для создания типизированных событий |
| `AnalyticsReporter` | interface | Реализуй для продакшна |
| `NoopAnalyticsReporter` | concrete | Заглушка — ничего не делает, безопасна для разработки |

---

## Logger — как добавлять LogObserver'ы

`Logger` работает через наблюдателей: при каждом `logger.info(...)` он вызывает
`onLog()` у всех зарегистрированных `LogObserver`'ов. Сам `Logger` не трогаешь —
только добавляешь/убираешь наблюдателей.

### Уже настроено в starter.dart

```dart
final logger = createAppLogger(
  observers: [
    ErrorReporterLogObserver(errorReporter), // ошибки идут в ErrorReportingService
    if (!kReleaseMode)
      const PrintingLogObserver(logLevel: LogLevel.trace), // печать в консоль
  ],
);
```

### Как написать свой LogObserver

```dart
// packages/monitoring/lib/src/file_log_observer.dart
final class FileLogObserver with LogObserver {
  @override
  void onLog(LogMessage logMessage) {
    File('app.log').writeAsStringSync(
      '${logMessage.timestamp} [${logMessage.level.toShortName()}] ${logMessage.message}\n',
      mode: FileMode.append,
    );
  }
}
```

### Как подключить

```dart
// composition.dart — добавляешь в список observers
observers: [
  ErrorReporterLogObserver(errorReporter),
  if (!kReleaseMode)
    const PrintingLogObserver(logLevel: LogLevel.trace),
  FileLogObserver(), // ← добавил
],
```

---

## ErrorReportingService — как заменить заглушку

`NoopErrorReporter` — заглушка: принимает ошибки, но ничего с ними не делает.
Для продакшна нужно реализовать `ErrorReportingService`.

### Сейчас (заглушка)

```dart
// composition.dart
Future<ErrorReportingService> createErrorReporter(ApplicationConfig config) async {
  const errorReporter = NoopErrorReporter(); // ← ничего не делает
  if (config.enableSentry) await errorReporter.initialize();
  return errorReporter;
}
```

### Как написать реальную реализацию (пример: Sentry)

```dart
// packages/monitoring/lib/src/sentry_error_reporter.dart
import 'package:sentry_flutter/sentry_flutter.dart';

final class SentryErrorReporter implements ErrorReportingService {
  @override
  bool get isInitialized => Sentry.isEnabled;

  @override
  Future<void> initialize() => SentryFlutter.init((options) {
    options.dsn = 'твой DSN из sentry.io';
  });

  @override
  Future<void> close() => Sentry.close();

  @override
  Future<void> captureException({
    required Object throwable,
    StackTrace? stackTrace,
  }) => Sentry.captureException(throwable, stackTrace: stackTrace);
}
```

### Как подключить — меняешь одну строчку

```dart
// было:
const errorReporter = NoopErrorReporter();
// стало:
final errorReporter = SentryErrorReporter();
```

Всё остальное (`DependenciesContainer`, BLoC, `starter.dart`) не трогаешь —
они работают через интерфейс `ErrorReportingService`.

---

## AnalyticsReporter — как использовать

`NoopAnalyticsReporter` — заглушка: принимает события, но не отправляет их.
Для продакшна нужно реализовать `AnalyticsReporter`.

### 1. Добавь в DependenciesContainer

```dart
// dependency_container.dart
class DependenciesContainer {
  const DependenciesContainer({
    required this.logger,
    required this.errorReporter,
    required this.analyticsReporter, // ← добавил
    // ...
  });

  final AnalyticsReporter analyticsReporter;
  // ...
}
```

### 2. Создай в composition.dart

```dart
Future<DependenciesContainer> createDependenciesContainer(...) async {
  const analyticsReporter = NoopAnalyticsReporter(); // ← заглушка
  if (config.enableAnalytics) await analyticsReporter.initialize();

  return DependenciesContainer(
    analyticsReporter: analyticsReporter,
    // ...
  );
}
```

### 3. Создай типизированные события в feature-пакете

```dart
// packages/features/notes/lib/src/analytics/notes_events.dart
import 'package:monitoring/monitoring.dart';

class NoteCreatedEvent extends AnalyticsEvent {
  const NoteCreatedEvent({required this.noteId});
  final String noteId;

  @override
  String get name => 'note_created';

  @override
  Map<String, Object?> get parameters => {'note_id': noteId};
}

class NoteDeletedEvent extends AnalyticsEvent {
  const NoteDeletedEvent({required this.noteId});
  final String noteId;

  @override
  String get name => 'note_deleted';

  @override
  Map<String, Object?> get parameters => {'note_id': noteId};
}
```

### 4. Используй в BLoC

```dart
// notes_bloc.dart
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc({required this.analyticsReporter}) : super(NotesInitial()) {
    on<NoteCreated>(_onNoteCreated);
  }

  final AnalyticsReporter analyticsReporter;

  Future<void> _onNoteCreated(NoteCreated event, Emitter<NotesState> emit) async {
    // ... логика создания заметки ...
    await analyticsReporter.logEvent(NoteCreatedEvent(noteId: note.id));
  }
}
```

### Как написать реальную реализацию (пример: Firebase Analytics)

```dart
// packages/monitoring/lib/src/firebase_analytics_reporter.dart
import 'package:firebase_analytics/firebase_analytics.dart';

final class FirebaseAnalyticsReporter implements AnalyticsReporter {
  FirebaseAnalyticsReporter() : _analytics = FirebaseAnalytics.instance;
  final FirebaseAnalytics _analytics;
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp();
    _initialized = true;
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> logEvent(AnalyticsEvent event) =>
      _analytics.logEvent(name: event.name, parameters: event.parameters);

  @override
  Future<void> setUserId(String? userId) => _analytics.setUserId(id: userId);
}
```

### Как подключить — меняешь одну строчку

```dart
// было:
const analyticsReporter = NoopAnalyticsReporter();
// стало:
final analyticsReporter = FirebaseAnalyticsReporter();
```

---

## Итого

```
Logger
  └── PrintingLogObserver     — уже подключён (консоль, только debug/profile)
  └── ErrorReporterLogObserver — уже подключён (пробрасывает ошибки в ErrorReporter)
  └── FileLogObserver          — напишешь сам когда нужно
  └── SentryLogObserver        — напишешь сам когда нужно

ErrorReportingService
  └── NoopErrorReporter        — сейчас (заглушка)
  └── SentryErrorReporter      — заменишь когда нужно

AnalyticsReporter
  └── NoopAnalyticsReporter          — сейчас (заглушка)
  └── FirebaseAnalyticsReporter      — заменишь когда нужно
```
