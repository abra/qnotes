part of 'note_details_screen.dart';

class _InlineColorPanel extends StatelessWidget {
  const _InlineColorPanel({
    required this.selected,
    required this.onSelected,
  });

  final NoteColor selected;
  final ValueChanged<NoteColor> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return _PanelBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.small,
          vertical: Spacing.medium,
        ),
        child: SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: NoteColor.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: Spacing.small),
            itemBuilder: (context, index) {
              final color = NoteColor.values[index];
              final isSelected = color == selected;
              return GestureDetector(
                onTap: () => onSelected(color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color == NoteColor.none
                        ? colorScheme.surfaceContainerHighest
                        : color.forBrightness(brightness),
                    border: isSelected
                        ? Border.all(
                            color: colorScheme.primary,
                            width: 2.5,
                          )
                        : Border.all(color: Colors.transparent),
                  ),
                  child: color == NoteColor.none
                      ? Icon(
                          Icons.block,
                          size: IconSize.xSmall,
                          color: colorScheme.onSurface,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
