// TODO: Delete this file when all packages are implemented.
// All classes below are temporary fakes — replace with real implementations from packages.

import 'dart:async';
import 'dart:ui' show Color, Locale;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── packages/monitoring (logger) ─────────────────────────────────────────────

/// TODO: Replace with LogMessage from packages/monitoring package.
class LogMessage {
  const LogMessage({
    required this.message,
    required this.level,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });

  final String message;
  final LogLevel level;
  final DateTime timestamp;
  final Object? error;
  final StackTrace? stackTrace;
}

/// TODO: Replace with LogLevel from packages/monitoring package.
enum LogLevel implements Comparable<LogLevel> {
  trace._(),
  debug._(),
  info._(),
  warn._(),
  error._(),
  fatal._();

  const LogLevel._();

  @override
  int compareTo(LogLevel other) => index - other.index;
}

/// TODO: Replace with LogObserver from packages/monitoring package.
mixin LogObserver {
  void onLog(LogMessage logMessage);
}

/// TODO: Replace with PrintingLogObserver from packages/monitoring package.
final class PrintingLogObserver with LogObserver {
  const PrintingLogObserver({required this.logLevel});

  final LogLevel logLevel;

  @override
  void onLog(LogMessage logMessage) {
    if (logMessage.level.index >= logLevel.index) {
      debugPrint(
        '[${logMessage.level.name.toUpperCase()}] ${logMessage.message}'
        '${logMessage.error != null ? '\n${logMessage.error}' : ''}',
      );
    }
  }
}

/// TODO: Replace with ErrorReporterLogObserver from packages/monitoring package.
final class ErrorReporterLogObserver with LogObserver {
  const ErrorReporterLogObserver(this._errorReporter);

  final ErrorReporter _errorReporter;

  @override
  void onLog(LogMessage logMessage) {
    if (!_errorReporter.isInitialized) return;

    if (logMessage.level.index >= LogLevel.error.index) {
      _errorReporter.captureException(
        throwable: logMessage.error ?? logMessage.message,
        stackTrace: logMessage.stackTrace,
      );
    }
  }
}

/// TODO: Replace with Logger from packages/monitoring package.
base class Logger {
  Logger({List<LogObserver>? observers}) {
    _observers.addAll(observers ?? []);
  }

  final _observers = <LogObserver>{};

  void addObserver(LogObserver observer) => _observers.add(observer);

  void removeObserver(LogObserver observer) => _observers.remove(observer);

  void trace(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, LogLevel.trace, error, stackTrace);

  void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, LogLevel.debug, error, stackTrace);

  void info(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, LogLevel.info, error, stackTrace);

  void warn(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, LogLevel.warn, error, stackTrace);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, LogLevel.error, error, stackTrace);

  void fatal(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, LogLevel.fatal, error, stackTrace);

  void _log(
    String message,
    LogLevel level,
    Object? error,
    StackTrace? stackTrace,
  ) {
    final logMessage = LogMessage(
      message: message,
      level: level,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
    for (final observer in _observers) {
      observer.onLog(logMessage);
    }
  }

  /// TODO: Replace with logger.logFlutterError from packages/monitoring.
  void logFlutterError(FlutterErrorDetails details) => error(
    'Flutter Error',
    error: details.exception,
    stackTrace: details.stack,
  );

  /// TODO: Replace with logger.logPlatformDispatcherError from packages/monitoring.
  bool logPlatformDispatcherError(Object error, StackTrace stackTrace) {
    this.error('Platform Error', error: error, stackTrace: stackTrace);
    return true;
  }

  /// TODO: Replace with logger.logZoneError from packages/monitoring.
  void logZoneError(Object error, StackTrace stackTrace) =>
      this.error('Zone Error', error: error, stackTrace: stackTrace);
}

// ─── packages/monitoring (error_reporter) ─────────────────────────────────────

/// TODO: Replace with ErrorReporter from packages/monitoring package.
abstract interface class ErrorReporter {
  bool get isInitialized;

  /// TODO: Replace with real initialization (e.g. Sentry.init).
  Future<void> initialize();

  Future<void> close();

  Future<void> captureException({
    required Object throwable,
    StackTrace? stackTrace,
  });
}

/// TODO: Replace with concrete ErrorReporter implementation from packages/monitoring.
final class NoopErrorReporter implements ErrorReporter {
  const NoopErrorReporter();

  @override
  bool get isInitialized => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> captureException({
    required Object throwable,
    StackTrace? stackTrace,
  }) async {}
}

// ─── packages/features/settings ───────────────────────────────────────────────

/// TODO: Replace with ThemeModeVO from packages/features/settings.
enum ThemeModeVO { light, dark, system }

/// TODO: Replace with GeneralSettings from packages/features/settings.
final class GeneralSettings {
  const GeneralSettings({
    this.locale = const Locale('en'),
    this.themeMode = ThemeModeVO.system,
    this.seedColor = const Color(0xFF6200EE),
  });

  final ThemeModeVO themeMode;
  final Color seedColor;
  final Locale locale;

  GeneralSettings copyWith({
    ThemeModeVO? themeMode,
    Color? seedColor,
    Locale? locale,
  }) => GeneralSettings(
    themeMode: themeMode ?? this.themeMode,
    seedColor: seedColor ?? this.seedColor,
    locale: locale ?? this.locale,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneralSettings &&
          seedColor == other.seedColor &&
          themeMode == other.themeMode &&
          locale == other.locale;

  @override
  int get hashCode => Object.hash(seedColor, themeMode, locale);
}

/// TODO: Replace with Settings from packages/features/settings.
class Settings {
  const Settings({this.general = const GeneralSettings()});

  final GeneralSettings general;

  Settings copyWith({GeneralSettings? general}) =>
      Settings(general: general ?? this.general);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Settings && other.general == general);

  @override
  int get hashCode => general.hashCode;
}

/// TODO: Replace with SettingsService from packages/features/settings.
class SettingsService {
  Settings _current = const Settings();
  final _controller = StreamController<Settings>.broadcast();

  Stream<Settings> get stream => _controller.stream;

  Settings get current => _current;

  Future<void> update(Settings Function(Settings) transform) async {
    _current = transform(_current);
    _controller.add(_current);
  }
}

/// TODO: Replace with SettingsContainer from packages/features/settings.
class SettingsContainer {
  const SettingsContainer({required this.settingsService});

  final SettingsService settingsService;

  /// TODO: Replace with real settings loading from SharedPreferences.
  static Future<SettingsContainer> create({
    required SharedPreferencesAsync sharedPreferences,
  }) async => SettingsContainer(settingsService: SettingsService());
}
