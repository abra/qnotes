import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preferences_bottom_sheet/preferences_bottom_sheet.dart';
import 'package:preferences_repository/preferences_repository.dart';
import 'package:shared/shared.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const _testLanguages = <SupportedLanguage>[
  (code: 'en', name: 'English'),
  (code: 'ru', name: 'Русский'),
];

Future<PreferencesService> _createService() => PreferencesService.create(
  supportedCodes: _testLanguages.map((l) => l.code).toList(),
);

Widget _buildSheet(PreferencesService service) {
  return MaterialApp(
    localizationsDelegates: const [
      PreferencesLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('ru')],
    home: Scaffold(
      body: PreferencesBottomSheet(
        preferencesService: service,
        supportedLanguages: _testLanguages,
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('PreferencesBottomSheet', () {
    testWidgets('shows "Preferences" title', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      expect(find.text('Preferences'), findsOneWidget);
    });

    testWidgets('shows Theme, Notes view, List density, Language labels', (
      tester,
    ) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Notes view'), findsOneWidget);
      expect(find.text('List density'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets(
      'shows three SegmentedButtons (Theme, Notes view, List density)',
      (tester) async {
        final service = await _createService();
        await tester.pumpWidget(_buildSheet(service));

        expect(
          find.byWidgetPredicate((w) => w is SegmentedButton),
          findsNWidgets(3),
        );
      },
    );

    testWidgets('shows drag handle', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
            final box = c.constraints;
            return box != null && box.maxWidth == 32 && box.maxHeight == 4;
          })
          .toList();
      expect(containers, isNotEmpty);
    });

    testWidgets('updates theme preference on segment tap', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pump();

      expect(service.current.themeMode, ThemeMode.dark);
    });

    testWidgets('updates noteViewMode to list on segment tap', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      await tester.tap(find.byIcon(Icons.list));
      await tester.pump();

      expect(service.current.noteViewMode, NoteViewMode.list);
    });

    testWidgets('shows current language name on main page', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('navigates to language page on language tap', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('updates locale to RU via language page', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'ru');
      await tester.pump();
      await tester.tap(find.text('Русский'));
      await tester.pumpAndSettle();

      expect(service.current.locale.languageCode, 'ru');
    });

    testWidgets('back arrow returns to main page', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Preferences'), findsOneWidget);
    });

    testWidgets('rebuilds when service emits new locale', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      await service.update((p) => p.copyWith(locale: const Locale('ru')));
      await tester.pump();

      expect(find.text('Русский'), findsOneWidget);
    });
  });
}
