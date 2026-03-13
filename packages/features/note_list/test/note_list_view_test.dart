import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:note_list/src/note_list_bloc.dart';
import 'package:preferences_service/preferences_service.dart';
import 'package:shared/shared.dart';

import 'helpers/fake_note_repository.dart';

class _MockPreferencesService extends Mock implements PreferencesService {}

Note _note(String id, {String content = 'body', String? title}) => Note(
  id: id,
  title: title,
  content: content,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

Widget _buildView({required NoteListBloc bloc}) {
  return MaterialApp(
    home: BlocProvider<NoteListBloc>.value(
      value: bloc,
      child: const _NoteListViewStub(),
    ),
  );
}

class _NoteListViewStub extends StatelessWidget {
  const _NoteListViewStub();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteListBloc, NoteListState>(
      builder: (context, state) {
        if (state.status == NoteListStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final notes = state.filteredNotes;
        return Scaffold(
          appBar: AppBar(title: const Text('Nota')),
          body: notes.isEmpty
              ? const Center(child: Text('No notes yet'))
              : Center(
                  child: Text(
                    state.noteViewMode == NoteViewMode.grid ? 'grid' : 'list',
                  ),
                ),
        );
      },
    );
  }
}

void main() {
  group('NoteListView', () {
    late FakeNoteRepository repo;
    late _MockPreferencesService mockPrefs;
    late StreamController<Preferences> prefsController;

    setUp(() {
      repo = FakeNoteRepository();
      mockPrefs = _MockPreferencesService();
      prefsController = StreamController<Preferences>.broadcast();
      when(() => mockPrefs.current).thenReturn(const Preferences());
      when(() => mockPrefs.stream).thenAnswer((_) => prefsController.stream);
    });

    tearDown(() => prefsController.close());

    NoteListBloc makeBloc({Preferences? initial}) {
      if (initial != null) {
        when(() => mockPrefs.current).thenReturn(initial);
      }
      return NoteListBloc(noteRepository: repo, preferencesService: mockPrefs);
    }

    testWidgets('shows loading indicator while loading', (tester) async {
      final bloc = makeBloc();
      await tester.pumpWidget(_buildView(bloc: bloc));

      bloc.emit(const NoteListState(status: NoteListStatus.loading));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows "No notes yet" when list is empty', (tester) async {
      final bloc = makeBloc();
      await tester.pumpWidget(_buildView(bloc: bloc));

      bloc.emit(const NoteListState(status: NoteListStatus.success));
      await tester.pump();

      expect(find.text('No notes yet'), findsOneWidget);
    });

    testWidgets('shows grid label when viewMode is grid', (tester) async {
      final notes = [_note('1'), _note('2')];
      final bloc = makeBloc();
      await tester.pumpWidget(_buildView(bloc: bloc));

      bloc.emit(NoteListState(status: NoteListStatus.success, notes: notes));
      await tester.pump();

      expect(find.text('grid'), findsOneWidget);
    });

    testWidgets('shows list label when viewMode is list', (tester) async {
      final notes = [_note('1')];
      final bloc = makeBloc(
        initial: const Preferences(noteViewMode: NoteViewMode.list),
      );
      await tester.pumpWidget(_buildView(bloc: bloc));

      bloc.emit(
        NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          noteViewMode: NoteViewMode.list,
        ),
      );
      await tester.pump();

      expect(find.text('list'), findsOneWidget);
    });

    testWidgets('switches to list view when preferences emit list mode', (
      tester,
    ) async {
      final notes = [_note('1')];
      repo = FakeNoteRepository(notes: notes);
      final bloc = makeBloc();
      bloc.add(NoteListStarted());
      await tester.pumpWidget(_buildView(bloc: bloc));
      await tester.pumpAndSettle();

      expect(find.text('grid'), findsOneWidget);

      prefsController.add(const Preferences(noteViewMode: NoteViewMode.list));
      await tester.pumpAndSettle();

      expect(find.text('list'), findsOneWidget);
    });
  });
}
