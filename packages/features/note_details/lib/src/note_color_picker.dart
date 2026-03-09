part of 'note_details_screen.dart';

class _NoteColorPicker extends StatelessWidget {
  const _NoteColorPicker({
    required this.selected,
    required this.onSelected,
    required this.onDismiss,
  });

  final NoteColor selected;
  final ValueChanged<NoteColor> onSelected;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xLarge,
          vertical: Spacing.mediumLarge,
        ),
        child: Wrap(
          spacing: Spacing.mediumLarge,
          runSpacing: Spacing.mediumLarge,
          children: NoteColor.values.map((color) {
            final isSelected = color == selected;
            return GestureDetector(
              onTap: () {
                onSelected(color);
                onDismiss();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color == NoteColor.none
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : color.forBrightness(Theme.of(context).brightness),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        )
                      : Border.all(color: Colors.transparent),
                ),
                child: color == NoteColor.none
                    ? Icon(
                        Icons.block,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
