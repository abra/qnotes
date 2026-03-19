import 'dart:async';

import 'package:component_library/component_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_files/image_files.dart';
import 'package:note_repository/note_repository.dart';
import 'package:preferences_service/preferences_service.dart';
import 'package:shared/shared.dart';
import 'package:smart_keyboard_insets/smart_keyboard_insets.dart';
import 'package:toast_service/toast_service.dart';

import 'l10n/note_list_localizations.dart';
import 'note_list_bloc.dart';
import 'note_paged_grid_view.dart';
import 'note_paged_list_view.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({
    super.key,
    required this.noteRepository,
    required this.preferencesService,
    required this.imageFiles,
    this.onNotePressed,
    this.onAddPressed,
    this.onSettingsPressed,
  });

  final NoteRepository noteRepository;
  final PreferencesService preferencesService;
  final ImageFiles imageFiles;
  final Future<Note?> Function(Note)? onNotePressed;
  final Future<Note?> Function()? onAddPressed;
  final void Function(BuildContext)? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteListBloc>(
      create: (_) => NoteListBloc(
        noteRepository: noteRepository,
        preferencesService: preferencesService,
        imageFiles: imageFiles,
      )..add(NoteListStarted()),
      child: NoteListView(
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
    this.onNotePressed,
    this.onAddPressed,
    this.onSettingsPressed,
  });

  final Future<Note?> Function(Note)? onNotePressed;
  final Future<Note?> Function()? onAddPressed;
  final void Function(BuildContext)? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteListBloc, NoteListState>(
      listenWhen: (prev, curr) => prev.deleteError != curr.deleteError,
      listener: (context, state) {
        if (state.deleteError != null) {
          final l10n = NoteListLocalizations.of(context)!;
          showToast(
            context,
            type: NotificationType.error,
            message: l10n.noteDeleteFailed,
          );
        }
      },
      buildWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.notes != curr.notes ||
          prev.selectedIds != curr.selectedIds ||
          prev.query != curr.query ||
          prev.noteViewMode != curr.noteViewMode ||
          prev.noteListDensity != curr.noteListDensity,
      builder: (context, state) {
        return _NoteListScaffold(
          state: state,
          viewMode: state.noteViewMode,
          density: state.noteListDensity,
          onNotePressed: onNotePressed,
          onAddPressed: onAddPressed,
          onSettingsPressed: onSettingsPressed,
        );
      },
    );
  }
}

// Height of the floating bottom bar + its bottom offset, used as scroll
// clearance so the last note is not hidden behind the bar.
const double _bottomBarClearance = 70;

class _NoteListScaffold extends StatefulWidget {
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
  final Future<Note?> Function(Note)? onNotePressed;
  final Future<Note?> Function()? onAddPressed;
  final void Function(BuildContext)? onSettingsPressed;

  @override
  State<_NoteListScaffold> createState() => _NoteListScaffoldState();
}

class _NoteListScaffoldState extends State<_NoteListScaffold> {
  StreamSubscription<KeyboardMetrics>? _keyboardSub;
  KeyboardMetrics _keyboardMetrics = KeyboardMetrics.hidden;

  @override
  void initState() {
    super.initState();
    _keyboardSub = SmartKeyboardInsets.instance.metricsStream.listen(
      (metrics) {
        if (!mounted) return;
        setState(() => _keyboardMetrics = metrics);
      },
    );
  }

  @override
  void dispose() {
    _keyboardSub?.cancel();
    super.dispose();
  }

  // Forwarding getters so build/methods below need no widget. prefix.
  NoteListState get state => widget.state;
  NoteViewMode get viewMode => widget.viewMode;
  NoteListDensity get density => widget.density;
  Future<Note?> Function(Note)? get onNotePressed => widget.onNotePressed;
  Future<Note?> Function()? get onAddPressed => widget.onAddPressed;
  void Function(BuildContext)? get onSettingsPressed =>
      widget.onSettingsPressed;

  Future<void> _openNote(BuildContext context, Note note) async {
    final updated = await onNotePressed!(note);
    if (!context.mounted) return;
    if (updated != null) {
      context.read<NoteListBloc>().add(NoteListNoteUpdated(updated));
    } else {
      context.read<NoteListBloc>().add(NoteListNoteRemoved(note.id));
    }
  }

  Future<void> _addNote(BuildContext context) async {
    final created = await onAddPressed!();
    if (!context.mounted) return;
    if (created != null) {
      context.read<NoteListBloc>().add(NoteListNoteAdded(created));
    }
  }

  void _deleteSelected(BuildContext context) {
    final count = state.selectedIds.length;
    final l10n = NoteListLocalizations.of(context)!;
    context.read<NoteListBloc>().add(NoteListSelectedDeleted());
    showToast(
      context,
      type: NotificationType.success,
      message: l10n.notesDeleted(count),
    );
  }

  void _deleteNote(BuildContext context, String id) {
    final l10n = NoteListLocalizations.of(context)!;
    context.read<NoteListBloc>().add(NoteListNoteDeleted(id));
    showToast(
      context,
      type: NotificationType.success,
      message: l10n.notesDeleted(1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NoteListBloc>();
    final notes = state.filteredNotes;
    final l10n = NoteListLocalizations.of(context)!;

    // On Android the plugin reports keyboard height from the physical bottom
    // (includes nav bar), while viewInsetsOf does not. Subtract safeAreaBottom
    // to get the correct content inset. On iOS safeAreaBottom is the static
    // home-indicator height and must NOT be subtracted (it's already accounted
    // for by SafeArea when the keyboard is hidden).
    final keyboardInset = _keyboardMetrics.isKeyboardVisible
        ? (defaultTargetPlatform == TargetPlatform.android
              ? _keyboardMetrics.keyboardHeight -
                    _keyboardMetrics.safeAreaBottom
              : _keyboardMetrics.keyboardHeight)
        : 0.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: state.isSelectionMode
          ? AppBar(
              scrolledUnderElevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.3),
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
          : AppBar(
              scrolledUnderElevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.small,
                children: const [
                  NotaLogo(size: 22),
                  Text('Nota'),
                ],
              ),
            ),
      body: SafeArea(
        child: Stack(
          children: [
            if (state.status == NoteListStatus.failure)
              ErrorState(
                message: l10n.loadFailed,
                retryLabel: l10n.retry,
                onRetry: () =>
                    context.read<NoteListBloc>().add(NoteListStarted()),
              )
            else if (state.status == NoteListStatus.loading)
              const CenteredCircularProgressIndicator()
            else if (notes.isEmpty && !state.isSelectionMode)
              EmptyState(message: l10n.emptyState)
            else if (viewMode == NoteViewMode.grid)
              NotePagedGridView(
                notes: notes,
                selectedIds: state.selectedIds,
                isSelectionMode: state.isSelectionMode,
                bottomPadding: state.isSelectionMode
                    ? 0
                    : _bottomBarClearance + keyboardInset,
                onNotePressed: onNotePressed == null
                    ? null
                    : (note) => _openNote(context, note),
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
                bottomPadding: state.isSelectionMode
                    ? 0
                    : _bottomBarClearance + keyboardInset,
                onNotePressed: onNotePressed == null
                    ? null
                    : (note) => _openNote(context, note),
                onNoteDeleted: (id) => _deleteNote(context, id),
                onNoteLongPressed: (id) =>
                    bloc.add(NoteListSelectionToggled(id)),
              ),
            if (!state.isSelectionMode)
              FadeGradientOverlay(height: _bottomBarClearance + keyboardInset),
            if (!state.isSelectionMode)
              Positioned(
                left: Spacing.mediumLarge,
                right: Spacing.mediumLarge,
                bottom: Spacing.mediumLarge + keyboardInset,
                child: _BottomBar(
                  onAddPressed: onAddPressed == null
                      ? null
                      : () => _addNote(context),
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

  final Future<void> Function()? onAddPressed;
  final ValueChanged<String>? onQueryChanged;
  final void Function(BuildContext)? onSettingsPressed;

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  static const _outerRadius = BorderRadius.all(
    Radius.circular(AppRadius.large),
  );
  static const _innerRadius = BorderRadius.all(
    Radius.circular(AppRadius.medium),
  );
  static const _iconSize = IconSize.xLarge;
  static const _buttonStyle = ButtonStyle(
    fixedSize: WidgetStatePropertyAll(Size(40, 32)),
    padding: WidgetStatePropertyAll(EdgeInsets.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

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
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8),
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.small),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 32,
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
                        size: _iconSize,
                      ),
                      hintStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      filled: true,
                      fillColor: colorScheme.surface,
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
                        vertical: Spacing.small,
                      ),
                      suffixIcon: value.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close,
                                size: IconSize.small,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              onPressed: _clear,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 28,
              child: VerticalDivider(
                width: Spacing.medium,
                thickness: 0.5,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: _innerRadius,
              ),
              child: IconButton(
                style: _buttonStyle,
                icon: Icon(
                  Icons.menu,
                  color: colorScheme.onSurfaceVariant,
                  size: _iconSize,
                ),
                onPressed: widget.onSettingsPressed == null
                    ? null
                    : () => widget.onSettingsPressed!(context),
              ),
            ),
            const SizedBox(width: Spacing.small),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: _innerRadius,
              ),
              child: IconButton(
                style: _buttonStyle,
                icon: Icon(
                  Icons.add,
                  color: colorScheme.onPrimary,
                  size: _iconSize,
                ),
                onPressed: widget.onAddPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
