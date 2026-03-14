import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_details/src/l10n/note_details_localizations.dart';
import 'package:note_details/src/note_details_bloc.dart';
import 'package:note_details/src/note_details_screen.dart';
import 'package:shared/shared.dart';

import 'helpers/fake_note_repository.dart';

final _existingNote = Note(
  id: '1',
  title: 'My note',
  content: 'Some content',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

Widget _buildView(NoteDetailsBloc bloc) {
  return MaterialApp(
    localizationsDelegates: const [
      NoteDetailsLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: BlocProvider<NoteDetailsBloc>.value(
      value: bloc,
      child: const NoteDetailsView(),
    ),
  );
}

/// Builds an app that navigates to [NoteDetailsView] when 'open' is tapped.
/// Returns the widget + captures the pop result in [result].
Widget _buildNavigationView(
  NoteDetailsBloc bloc,
  void Function(Note?) capture,
) {
  return MaterialApp(
    localizationsDelegates: const [
      NoteDetailsLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: BlocProvider<NoteDetailsBloc>.value(
      value: bloc,
      child: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            final result = await Navigator.of(context).push<Note?>(
              MaterialPageRoute<Note?>(
                builder: (_) => BlocProvider<NoteDetailsBloc>.value(
                  value: bloc,
                  child: const NoteDetailsView(),
                ),
              ),
            );
            capture(result);
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
}

void main() {
  group('NoteDetailsView', () {
    // --- AppBar title ---

    testWidgets('shows "New note" title for a new note', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        isNew: true,
      );
      await tester.pumpWidget(_buildView(bloc));

      expect(find.text('New note'), findsOneWidget);
    });

    testWidgets('shows "Edit note" title for an existing note', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(notes: [_existingNote]),
        isNew: false,
      );
      bloc.emit(
        NoteDetailsState(
          isNew: false,
          status: NoteDetailsStatus.success,
          note: _existingNote,
          title: 'My note',
          content: 'Some content',
        ),
      );
      await tester.pumpWidget(_buildView(bloc));

      expect(find.text('Edit note'), findsOneWidget);
    });

    // --- Initial UI elements ---

    testWidgets('renders back button, pin icon and color icon', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        isNew: true,
      );
      await tester.pumpWidget(_buildView(bloc));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.push_pin_outlined), findsOneWidget);
      expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
    });

    testWidgets('renders title and content text fields with hint text', (
      tester,
    ) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        isNew: true,
      );
      await tester.pumpWidget(_buildView(bloc));

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Start typing...'), findsOneWidget);
    });

    testWidgets('shows filled pin icon when note is pinned', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        isNew: true,
      );
      bloc.emit(const NoteDetailsState(isPinned: true));
      await tester.pumpWidget(_buildView(bloc));
      await tester.pump();

      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });

    // --- Text field interactions ---

    testWidgets('typing in title field updates bloc state', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        isNew: true,
      );
      await tester.pumpWidget(_buildView(bloc));

      await tester.enterText(find.byType(TextField).first, 'Hello title');
      await tester.pump();

      expect(bloc.state.title, 'Hello title');
    });

    testWidgets('typing in content field updates bloc state', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        isNew: true,
      );
      await tester.pumpWidget(_buildView(bloc));

      await tester.enterText(find.byType(TextField).last, 'Hello content');
      await tester.pump();

      expect(bloc.state.content, 'Hello content');
    });

    // --- Back button navigation ---

    testWidgets('back button pops with null when both fields are empty', (
      tester,
    ) async {
      Note? result;
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        isNew: true,
      );
      await tester.pumpWidget(_buildNavigationView(bloc, (n) => result = n));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('back button with title only saves note', (tester) async {
      Note? result;
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        isNew: true,
      );
      await tester.pumpWidget(_buildNavigationView(bloc, (n) => result = n));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Title only');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.title, 'Title only');
      expect(result!.content, '');
    });

    testWidgets('back button with content only saves note', (tester) async {
      Note? result;
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        isNew: true,
      );
      await tester.pumpWidget(_buildNavigationView(bloc, (n) => result = n));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'Content only');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.title, isNull);
      expect(result!.content, 'Content only');
    });

    testWidgets('back button with both fields filled saves note', (
      tester,
    ) async {
      Note? result;
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        isNew: true,
      );
      await tester.pumpWidget(_buildNavigationView(bloc, (n) => result = n));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'My title');
      await tester.pump();
      await tester.enterText(find.byType(TextField).last, 'My content');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.title, 'My title');
      expect(result!.content, 'My content');
    });
  });
}
