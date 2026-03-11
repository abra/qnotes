import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preferences_repository/preferences_repository.dart';
import 'package:shared/shared.dart';
import 'package:toastification/toastification.dart';

import 'l10n/note_list_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Preferences>(
      stream: preferencesService.stream,
      initialData: preferencesService.current,
      builder: (context, snapshot) {
        final viewMode = snapshot.data?.noteViewMode ?? NoteViewMode.grid;
        final density =
            snapshot.data?.noteListDensity ?? NoteListDensity.threeLines;
        return BlocConsumer<NoteListBloc, NoteListState>(
          listenWhen: (prev, curr) => prev.deleteError != curr.deleteError,
          listener: (context, state) {
            if (state.deleteError != null) {
              final l10n = NoteListLocalizations.of(context)!;
              toastification.show(
                context: context,
                type: ToastificationType.error,
                style: ToastificationStyle.flat,
                title: Text(l10n.noteDeleteFailed),
                autoCloseDuration: const Duration(seconds: 3),
                alignment: Alignment.topCenter,
                animationBuilder: (context, animation, alignment, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            }
          },
          buildWhen: (prev, curr) =>
              prev.status != curr.status ||
              prev.notes != curr.notes ||
              prev.selectedIds != curr.selectedIds ||
              prev.query != curr.query,
          builder: (context, state) {
            return _NoteListScaffold(
              state: state,
              viewMode: viewMode,
              density: density,
              onNotePressed: onNotePressed,
              onAddPressed: onAddPressed,
              onSettingsPressed: onSettingsPressed,
            );
          },
        );
      },
    );
  }
}

class _NoteListScaffold extends StatelessWidget {
  const _NoteListScaffold({
    required this.state,
    required this.viewMode,
    required this.density,
    this.onNotePressed,
    this.onAddPressed,
    this.onSettingsPressed,
  });

  final NoteListState state;
  final NoteViewMode viewMode;
  final NoteListDensity density;
  final Future<void> Function(Note)? onNotePressed;
  final Future<void> Function()? onAddPressed;
  final VoidCallback? onSettingsPressed;

  Future<void> _navigateAndRefresh(
    BuildContext context,
    Future<void> Function() navigate,
  ) async {
    await navigate();
    if (context.mounted) {
      context.read<NoteListBloc>().add(NoteListStarted());
    }
  }

  void _deleteSelected(BuildContext context) {
    final count = state.selectedIds.length;
    final l10n = NoteListLocalizations.of(context)!;
    context.read<NoteListBloc>().add(NoteListSelectedDeleted());
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(l10n.notesDeleted(count)),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      animationBuilder: (context, animation, alignment, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  void _deleteNote(BuildContext context, String id) {
    final l10n = NoteListLocalizations.of(context)!;
    context.read<NoteListBloc>().add(NoteListNoteDeleted(id));
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(l10n.notesDeleted(1)),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      animationBuilder: (context, animation, alignment, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NoteListBloc>();
    final notes = state.filteredNotes;
    final l10n = NoteListLocalizations.of(context)!;

    return Scaffold(
      appBar: state.isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => bloc.add(NoteListSelectionCleared()),
              ),
              title: Text(l10n.selected(state.selectedIds.length)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteSelected(context),
                ),
              ],
            )
          : AppBar(title: const Text('Nota')),
      body: SafeArea(
        child: Stack(
          children: [
            if (state.status == NoteListStatus.loading)
              const Center(child: CircularProgressIndicator())
            else if (notes.isEmpty && !state.isSelectionMode)
              Center(child: Text(l10n.emptyState))
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
                density: density,
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
                left: Spacing.medium,
                right: Spacing.medium,
                bottom: Spacing.mediumLarge,
                child: _BottomBar(
                  onAddPressed: onAddPressed == null
                      ? null
                      : () => _navigateAndRefresh(context, onAddPressed!),
                  onQueryChanged: (q) => bloc.add(NoteListQueryChanged(q)),
                  onSettingsPressed: onSettingsPressed,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatefulWidget {
  const _BottomBar({
    this.onAddPressed,
    this.onQueryChanged,
    this.onSettingsPressed,
  });

  final VoidCallback? onAddPressed;
  final ValueChanged<String>? onQueryChanged;
  final VoidCallback? onSettingsPressed;

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  static const _outerRadius = BorderRadius.all(Radius.circular(20));
  static const _innerRadius = BorderRadius.all(Radius.circular(14));

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onQueryChanged?.call('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = NoteListLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: _outerRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.small),
        child: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) => TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: widget.onQueryChanged,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: const OutlineInputBorder(
                      borderRadius: _innerRadius,
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: _innerRadius,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: _innerRadius,
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: Spacing.medium,
                    ),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: _clear,
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Spacing.small),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: _innerRadius,
              ),
              child: IconButton(
                icon: Icon(Icons.menu, color: colorScheme.onSurfaceVariant),
                onPressed: widget.onSettingsPressed,
              ),
            ),
            const SizedBox(width: Spacing.small),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: _innerRadius,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: widget.onAddPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
