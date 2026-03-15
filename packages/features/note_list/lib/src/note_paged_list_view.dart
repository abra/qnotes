import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'note_card.dart';

class NotePagedListView extends StatelessWidget {
  const NotePagedListView({
    super.key,
    required this.notes,
    required this.density,
    required this.selectedIds,
    required this.isSelectionMode,
    this.onNotePressed,
    this.onNoteDeleted,
    this.onNoteLongPressed,
    this.bottomPadding = 0,
  });

  final List<Note> notes;
  final NoteListDensity density;
  final Set<String> selectedIds;
  final bool isSelectionMode;
  final ValueChanged<Note>? onNotePressed;
  final ValueChanged<String>? onNoteDeleted;
  final ValueChanged<String>? onNoteLongPressed;
  final double bottomPadding;

  static const _dismissRadius = BorderRadius.all(
    Radius.circular(AppRadius.small),
  );

  // When a note has no header (no title, not pinned) we give it one extra
  // content line so the card height roughly matches a note that has a title.
  int _contentMaxLines(Note note) {
    final hasHeader = note.title != null || note.isPinned;
    return switch (density) {
      NoteListDensity.twoLines => hasHeader ? 1 : 2,
      NoteListDensity.threeLines => hasHeader ? 2 : 3,
      NoteListDensity.fourLines => hasHeader ? 3 : 4,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        Spacing.medium,
        Spacing.medium,
        Spacing.medium,
        Spacing.medium + bottomPadding,
      ),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: Spacing.small),
      itemBuilder: (context, index) {
        final note = notes[index];
        final isSelected = selectedIds.contains(note.id);

        final card = NoteCard(
          key: ValueKey(note.id),
          note: note,
          isSelected: isSelected,
          titleMaxLines: 1,
          contentMaxLines: _contentMaxLines(note),
          onPressed: isSelectionMode
              ? () => onNoteLongPressed?.call(note.id)
              : () => onNotePressed?.call(note),
          onLongPress: isSelectionMode
              ? null
              : () => onNoteLongPressed?.call(note.id),
          onDeleted: () => onNoteDeleted?.call(note.id),
        );

        final constrainedCard = ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Spacing.xxxLarge),
          child: card,
        );

        if (isSelectionMode) return constrainedCard;

        return ClipRRect(
          borderRadius: _dismissRadius,
          child: Dismissible(
            key: ValueKey(note.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => onNoteDeleted?.call(note.id),
            background: ColoredBox(
              color: Theme.of(context).colorScheme.error,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: Spacing.large),
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
            ),
            child: constrainedCard,
          ),
        );
      },
    );
  }
}
