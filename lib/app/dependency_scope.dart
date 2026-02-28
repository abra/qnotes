// InheritedWidget — provides a DependencyContainer to the widget tree

import 'package:flutter/widgets.dart';
import 'package:qnotes/app/app_settings_scope.dart';
import 'package:qnotes/bootstrap/dependency_container.dart';
import 'package:qnotes/utils/inherited_extension.dart';

/// A scope that provides [DependenciesContainer] to the application.
class DependenciesScope extends StatelessWidget {
  const DependenciesScope({
    required this.dependencies,
    required this.child,
    super.key,
  });

  final DependenciesContainer dependencies;
  final Widget child;

  /// Get the dependencies from the [context].
  static DependenciesContainer of(BuildContext context) =>
      context.inhOf<_DependenciesInherited>(listen: false).dependencies;

  @override
  Widget build(BuildContext context) {
    return _DependenciesInherited(
      dependencies: dependencies,
      child: AppSettingsScope(child: child),
    );
  }
}

class _DependenciesInherited extends InheritedWidget {
  const _DependenciesInherited({
    required super.child,
    required this.dependencies,
  });

  final DependenciesContainer dependencies;

  @override
  bool updateShouldNotify(_DependenciesInherited oldWidget) =>
      !identical(dependencies, oldWidget.dependencies);
}
