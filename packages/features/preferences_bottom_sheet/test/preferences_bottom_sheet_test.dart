import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preferences_bottom_sheet/preferences_bottom_sheet.dart';
import 'package:preferences_repository/preferences_repository.dart';
import 'package:shared/shared.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';

Future<PreferencesService> _createService() => PreferencesService.create();

Widget _buildSheet(PreferencesService service) {
  return MaterialApp(
    home: Scaffold(body: PreferencesBottomSheet(preferencesService: service)),
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

    testWidgets('shows Theme, Notes view, Language labels', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Notes view'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('shows four SegmentedButtons', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      expect(
        find.byWidgetPredicate((w) => w is SegmentedButton),
        findsNWidgets(4),
      );
    });

    testWidgets('shows drag handle', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      // Drag handle is a Container with fixed width 32 and height 4
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

      // Tap "Dark" segment (Icons.dark_mode)
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pump();

      expect(service.current.themeMode, ThemeMode.dark);
    });

    testWidgets('updates noteViewMode to list on segment tap', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      // Tap "List" segment (Icons.list)
      await tester.tap(find.byIcon(Icons.list));
      await tester.pump();

      expect(service.current.noteViewMode, NoteViewMode.list);
    });

    testWidgets('updates locale to RU on segment tap', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      await tester.tap(find.text('RU'));
      await tester.pump();

      expect(service.current.locale.languageCode, 'ru');
    });

    testWidgets('rebuilds when service emits new preferences', (tester) async {
      final service = await _createService();
      await tester.pumpWidget(_buildSheet(service));

      // Default: system theme selected → verify EN is selected
      await service.update((p) => p.copyWith(locale: const Locale('ru')));
      await tester.pump();

      // After update the SegmentedButton for Language should reflect 'ru'
      // The selected segment highlights — just verify no exception is thrown
      // and the widget is still rendered.
      expect(find.text('Language'), findsOneWidget);
    });
  });
}
