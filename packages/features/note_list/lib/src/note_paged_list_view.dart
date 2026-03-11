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
  });

  final List<Note> notes;
  final NoteListDensity density;
  final Set<String> selectedIds;
  final bool isSelectionMode;
  final ValueChanged<Note>? onNotePressed;
  final ValueChanged<String>? onNoteDeleted;
  final ValueChanged<String>? onNoteLongPressed;

  static const _dismissRadius = BorderRadius.all(Radius.circular(12));

  int get _contentMaxLines => switch (density) {
    NoteListDensity.twoLines => 1,
    NoteListDensity.threeLines => 2,
    NoteListDensity.fourLines => 3,
  };

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
          key: ValueKey(note.id),
          note: note,
          isSelected: isSelected,
          titleMaxLines: 1,
          contentMaxLines: _contentMaxLines,
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
              borderRadius: _dismissRadius,
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
