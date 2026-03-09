import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:preferences_repository/preferences_repository.dart';
import 'package:shared/shared.dart';

class PreferencesBottomSheet extends StatelessWidget {
  const PreferencesBottomSheet({super.key, required this.preferencesService});

  final PreferencesService preferencesService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Preferences>(
      stream: preferencesService.stream,
      initialData: preferencesService.current,
      builder: (context, snapshot) {
        final prefs = snapshot.data ?? preferencesService.current;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.mediumLarge,
              Spacing.small,
              Spacing.mediumLarge,
              Spacing.mediumLarge,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: Spacing.mediumLarge),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: Spacing.mediumLarge),
                _PreferenceRow(
                  label: 'Theme',
                  control: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                        tooltip: 'System',
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode),
                        tooltip: 'Light',
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                        tooltip: 'Dark',
                      ),
                    ],
                    selected: {prefs.themeMode},
                    onSelectionChanged: (value) => preferencesService.update(
                      (p) => p.copyWith(themeMode: value.first),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.medium),
                _PreferenceRow(
                  label: 'Notes view',
                  control: SegmentedButton<NoteViewMode>(
                    segments: const [
                      ButtonSegment(
                        value: NoteViewMode.grid,
                        icon: Icon(Icons.grid_view),
                        tooltip: 'Grid',
                      ),
                      ButtonSegment(
                        value: NoteViewMode.list,
                        icon: Icon(Icons.list),
                        tooltip: 'List',
                      ),
                    ],
                    selected: {prefs.noteViewMode},
                    onSelectionChanged: (value) => preferencesService.update(
                      (p) => p.copyWith(noteViewMode: value.first),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.medium),
                _PreferenceRow(
                  label: 'List density',
                  control: SegmentedButton<NoteListDensity>(
                    segments: const [
                      ButtonSegment(
                        value: NoteListDensity.twoLines,
                        label: Text('2'),
                        tooltip: '2 lines',
                      ),
                      ButtonSegment(
                        value: NoteListDensity.threeLines,
                        label: Text('3'),
                        tooltip: '3 lines',
                      ),
                      ButtonSegment(
                        value: NoteListDensity.fourLines,
                        label: Text('4'),
                        tooltip: '4 lines',
                      ),
                    ],
                    selected: {prefs.noteListDensity},
                    onSelectionChanged: (value) => preferencesService.update(
                      (p) => p.copyWith(noteListDensity: value.first),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.medium),
                _PreferenceRow(
                  label: 'Language',
                  control: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'en', label: Text('EN')),
                      ButtonSegment(value: 'ru', label: Text('RU')),
                    ],
                    selected: {prefs.locale.languageCode},
                    onSelectionChanged: (value) => preferencesService.update(
                      (p) => p.copyWith(locale: Locale(value.first)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({required this.label, required this.control});

  final String label;
  final Widget control;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        control,
      ],
    );
  }
}
