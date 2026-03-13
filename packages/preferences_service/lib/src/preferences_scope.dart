import 'package:flutter/widgets.dart';

import 'preferences.dart';
import 'preferences_service.dart';

/// Listens to [PreferencesService] and provides [Preferences] to the subtree.
class PreferencesScope extends StatelessWidget {
  const PreferencesScope({
    required this.service,
    required this.child,
    super.key,
  });

  final PreferencesService service;
  final Widget child;

  /// Returns current [Preferences] and subscribes to changes.
  static Preferences of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_PreferencesInherited>()!
      .preferences;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Preferences>(
      stream: service.stream,
      initialData: service.current,
      builder: (context, snapshot) {
        return _PreferencesInherited(preferences: snapshot.data!, child: child);
      },
    );
  }
}

class _PreferencesInherited extends InheritedWidget {
  const _PreferencesInherited({
    required super.child,
    required this.preferences,
  });

  final Preferences preferences;

  @override
  bool updateShouldNotify(_PreferencesInherited old) =>
      preferences != old.preferences;
}
