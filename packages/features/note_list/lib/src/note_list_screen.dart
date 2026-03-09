import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preferences_repository/preferences_repository.dart';
import 'package:shared/shared.dart';

import 'note_list_bloc.dart';
import 'note_paged_grid_view.dart';
import 'note_paged_list_view.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({
    super.key,
    required this.noteRepository,
    required this.preferencesService,
    this.onNotePressed,
    this.onAddPressed,
    this.onSettingsPressed,
  });

  final NoteRepository noteRepository;
  final PreferencesService preferencesService;
  final Future<void> Function(Note)? onNotePressed;
  final Future<void> Function()? onAddPressed;
  final VoidCallback? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteListBloc>(
      create: (_) =>
          NoteListBloc(noteRepository: noteRepository)..add(NoteListStarted()),
      child: NoteListView(
        preferencesService: preferencesService,
        onNotePressed: onNotePressed,
        onAddPressed: onAddPressed,
        onSettingsPressed: onSettingsPressed,
      ),
    );
  }
}

@visibleForTesting
class NoteListView extends StatelessWidget {
  const NoteListView({
    super.key,
    required this.preferencesService,
    this.onNotePressed,
    this.onAddPressed,
    this.onSettingsPressed,
  });

  final PreferencesService preferencesService;
  final Future<void> Function(Note)? onNotePressed;
  final Future<void> Function()? onAddPressed;
  final VoidCallback? onSettingsPressed;

  void _navigateAndRefresh(
    BuildContext context,
    Future<void> Function() navigate,
  ) async {
    await navigate();
    if (context.mounted) {
      context.read<NoteListBloc>().add(NoteListStarted());
    }
  }

  void _deleteSelected(BuildContext context, int count) {
    context.read<NoteListBloc>().add(NoteListSelectedDeleted());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count ${count == 1 ? 'note' : 'notes'} deleted'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteNote(BuildContext context, String id) {
    context.read<NoteListBloc>().add(NoteListNoteDeleted(id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteListBloc, NoteListState>(
      builder: (context, state) {
        final notes = state.filteredNotes;

        return StreamBuilder<Preferences>(
          stream: preferencesService.stream,
          initialData: preferencesService.current,
          builder: (context, snapshot) {
            final viewMode = snapshot.data?.noteViewMode ?? NoteViewMode.grid;
            return _buildScaffold(context, state, notes, viewMode);
          },
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    NoteListState state,
    List<Note> notes,
    NoteViewMode viewMode,
  ) {
    final bloc = context.read<NoteListBloc>();

    return Scaffold(
      appBar: state.isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => bloc.add(NoteListSelectionCleared()),
              ),
              title: Text('${state.selectedIds.length} selected'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      _deleteSelected(context, state.selectedIds.length),
                ),
              ],
            )
          : AppBar(
              title: const Text('Nota'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: onSettingsPressed,
                ),
              ],
            ),
      body: SafeArea(
        child: Stack(
          children: [
            if (state.status == NoteListStatus.loading)
              const Center(child: CircularProgressIndicator())
            else if (notes.isEmpty && !state.isSelectionMode)
              const Center(child: Text('No notes yet'))
            else if (viewMode == NoteViewMode.grid)
              NotePagedGridView(
                notes: notes,
                selectedIds: state.selectedIds,
                isSelectionMode: state.isSelectionMode,
                onNotePressed: onNotePressed == null
                    ? null
                    : (note) => _navigateAndRefresh(
                        context,
                        () => onNotePressed!(note),
                      ),
                onNoteDeleted: (id) => _deleteNote(context, id),
                onNoteLongPressed: (id) =>
                    bloc.add(NoteListSelectionToggled(id)),
              )
            else
              NotePagedListView(
                notes: notes,
                selectedIds: state.selectedIds,
                isSelectionMode: state.isSelectionMode,
                onNotePressed: onNotePressed == null
                    ? null
                    : (note) => _navigateAndRefresh(
                        context,
                        () => onNotePressed!(note),
                      ),
                onNoteDeleted: (id) => _deleteNote(context, id),
                onNoteLongPressed: (id) =>
                    bloc.add(NoteListSelectionToggled(id)),
              ),
            if (!state.isSelectionMode)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomBar(
                  viewMode: viewMode,
                  onAddPressed: onAddPressed == null
                      ? null
                      : () => _navigateAndRefresh(context, onAddPressed!),
                  onQueryChanged: (q) => bloc.add(NoteListQueryChanged(q)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.viewMode,
    this.onAddPressed,
    this.onQueryChanged,
  });

  final NoteViewMode viewMode;
  final VoidCallback? onAddPressed;
  final ValueChanged<String>? onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.medium,
          vertical: Spacing.small,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: onQueryChanged,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: Spacing.small),
            IconButton(icon: const Icon(Icons.add), onPressed: onAddPressed),
          ],
        ),
      ),
    );
  }
}
