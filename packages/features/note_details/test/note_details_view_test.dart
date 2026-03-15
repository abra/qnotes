import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_details/src/l10n/note_details_localizations.dart';
import 'package:note_details/src/note_details_bloc.dart';
import 'package:note_details/src/note_details_screen.dart';
import 'package:shared/shared.dart';

import 'helpers/fake_image_service.dart';
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
      FlutterQuillLocalizations.delegate,
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
      FlutterQuillLocalizations.delegate,
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
        imageService: FakeImageService(),
        isNew: true,
      );
      await tester.pumpWidget(_buildView(bloc));

      expect(find.text('New note'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('shows "Edit note" title for an existing note', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(notes: [_existingNote]),
        imageService: FakeImageService(),
        isNew: false,
      );
      bloc.emit(
        NoteDetailsState(
          isNew: false,
          status: NoteDetailsStatus.success,
          note: _existingNote,
          title: 'My note',
          content: 'Some content',
          originalContent: 'Some content',
        ),
      );
      await tester.pumpWidget(_buildView(bloc));

      expect(find.text('Edit note'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    // --- Initial UI elements ---

    testWidgets('renders back button, pin icon and color icon', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageService: FakeImageService(),
        isNew: true,
      );
      await tester.pumpWidget(_buildView(bloc));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.push_pin_outlined), findsOneWidget);
      expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('renders title text field and quill editor with hint text', (
      tester,
    ) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageService: FakeImageService(),
        isNew: true,
      );
      await tester.pumpWidget(_buildView(bloc));

      expect(find.byType(TextField), findsOneWidget); // title only
      expect(find.byType(QuillEditor), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('shows filled pin icon when note is pinned', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageService: FakeImageService(),
        isNew: true,
      );
      bloc.emit(const NoteDetailsState(isPinned: true));
      await tester.pumpWidget(_buildView(bloc));
      await tester.pump();

      expect(find.byIcon(Icons.push_pin), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    // --- Text field interactions ---

    testWidgets('typing in title field updates bloc state', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageService: FakeImageService(),
        isNew: true,
      );
      await tester.pumpWidget(_buildView(bloc));

      await tester.enterText(find.byType(TextField), 'Hello title');
      await tester.pump();

      expect(bloc.state.title, 'Hello title');
      await tester.pump(const Duration(seconds: 1));
    });

    // --- Back button navigation ---

    testWidgets('back button pops with null when both fields are empty', (
      tester,
    ) async {
      Note? result;
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageService: FakeImageService(),
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
        imageService: FakeImageService(),
        isNew: true,
      );
      await tester.pumpWidget(_buildNavigationView(bloc, (n) => result = n));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Title only');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.title, 'Title only');
    });
  });
}
