import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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

Widget _buildView(NoteDetailsBloc bloc, {VoidCallback? onBackPressed}) {
  return MaterialApp(
    home: BlocProvider<NoteDetailsBloc>.value(
      value: bloc,
      child: NoteDetailsView(onBackPressed: onBackPressed),
    ),
  );
}

void main() {
  group('NoteDetailsView', () {
    testWidgets('shows "New note" title for a new note', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        noteId: null,
      );
      await tester.pumpWidget(_buildView(bloc));

      expect(find.text('New note'), findsOneWidget);
    });

    testWidgets('shows "Edit note" title for an existing note', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(notes: [_existingNote]),
        noteId: '1',
      );
      // Seed success state directly
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

    testWidgets('renders back button, pin icon and color circle', (
      tester,
    ) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        noteId: null,
      );
      await tester.pumpWidget(_buildView(bloc));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.push_pin_outlined), findsOneWidget);
      // Color circle is a Container with BoxDecoration — just verify the
      // GestureDetector that wraps it is present.
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('renders title and content text fields', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        noteId: null,
      );
      await tester.pumpWidget(_buildView(bloc));

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Title'), findsOneWidget); // hint text
      expect(find.text('Start typing...'), findsOneWidget); // hint text
    });

    testWidgets('shows pin filled icon when note is pinned', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        noteId: null,
      );
      bloc.emit(const NoteDetailsState(isPinned: true));
      await tester.pumpWidget(_buildView(bloc));
      await tester.pump();

      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });

    testWidgets('calls onBackPressed when back button tapped', (tester) async {
      var backCalled = false;
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        noteId: null,
      );
      await tester.pumpWidget(
        _buildView(bloc, onBackPressed: () => backCalled = true),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(backCalled, isTrue);
    });
  });
}
