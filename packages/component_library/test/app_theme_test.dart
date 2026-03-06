import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _testApp({required Brightness brightness, required Widget child}) {
  return MaterialApp(
    theme: ThemeData(brightness: brightness),
    home: AppTheme(
      lightTheme: const LightAppThemeData(),
      darkTheme: const DarkAppThemeData(),
      child: child,
    ),
  );
}

void main() {
  group('AppTheme', () {
    testWidgets('of() returns LightAppThemeData when brightness is light', (
      tester,
    ) async {
      AppThemeData? result;

      await tester.pumpWidget(
        _testApp(
          brightness: Brightness.light,
          child: Builder(
            builder: (context) {
              result = AppTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result, isA<LightAppThemeData>());
    });

    testWidgets('of() returns DarkAppThemeData when brightness is dark', (
      tester,
    ) async {
      AppThemeData? result;

      await tester.pumpWidget(
        _testApp(
          brightness: Brightness.dark,
          child: Builder(
            builder: (context) {
              result = AppTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result, isA<DarkAppThemeData>());
    });

    testWidgets('updateShouldNotify returns false when themes are identical', (
      tester,
    ) async {
      var buildCount = 0;

      final widget = StatefulBuilder(
        builder: (context, setState) {
          return AppTheme(
            lightTheme: const LightAppThemeData(),
            darkTheme: const DarkAppThemeData(),
            child: Builder(
              builder: (context) {
                AppTheme.of(context); // subscribe
                buildCount++;
                return const SizedBox();
              },
            ),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: widget));
      final countAfterFirstBuild = buildCount;

      // Pump same themes — updateShouldNotify returns false, child should not rebuild
      await tester.pump();

      expect(buildCount, countAfterFirstBuild);
    });
  });
}
