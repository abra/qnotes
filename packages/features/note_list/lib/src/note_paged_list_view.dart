import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'note_card.dart';

class NotePagedListView extends StatelessWidget {
  const NotePagedListView({
    super.key,
    required this.notes,
    required this.selectedIds,
    required this.isSelectionMode,
    this.onNotePressed,
    this.onNoteDeleted,
    this.onNoteLongPressed,
  });

  final List<Note> notes;
  final Set<String> selectedIds;
  final bool isSelectionMode;
  final ValueChanged<Note>? onNotePressed;
  final ValueChanged<String>? onNoteDeleted;
  final ValueChanged<String>? onNoteLongPressed;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Spacing.medium),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: Spacing.small),
      itemBuilder: (context, index) {
        final note = notes[index];
        final isSelected = selectedIds.contains(note.id);

        final card = NoteCard(
          note: note,
          isSelected: isSelected,
          onPressed: isSelectionMode
              ? () => onNoteLongPressed?.call(note.id)
              : () => onNotePressed?.call(note),
          onLongPress: isSelectionMode
              ? null
              : () => onNoteLongPressed?.call(note.id),
          onDeleted: () => onNoteDeleted?.call(note.id),
        );

        if (isSelectionMode) return card;

        return Dismissible(
          key: ValueKey(note.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onNoteDeleted?.call(note.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: Spacing.large),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          child: card,
        );
      },
    );
  }
}
