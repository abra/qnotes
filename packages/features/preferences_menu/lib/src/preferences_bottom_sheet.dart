import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:preferences_service/preferences_service.dart';
import 'package:shared/shared.dart';

import 'l10n/preferences_localizations.dart';

enum _Page { main, language }

/// Bottom sheet with app preferences. Manages navigation between
/// the main settings page and the language selection page.
class PreferencesBottomSheet extends StatefulWidget {
  const PreferencesBottomSheet({super.key, required this.supportedLanguages});

  final List<SupportedLanguage> supportedLanguages;

  @override
  State<PreferencesBottomSheet> createState() => _PreferencesBottomSheetState();
}

class _PreferencesBottomSheetState extends State<PreferencesBottomSheet> {
  _Page _page = _Page.main;

  void _goToLanguage() => setState(() => _page = _Page.language);

  void _goToMain() => setState(() => _page = _Page.main);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: _slideTransition,
          child: _page == _Page.main
              ? _MainPage(
                  key: const ValueKey(_Page.main),
                  supportedLanguages: widget.supportedLanguages,
                  onLanguageTap: _goToLanguage,
                )
              : _LanguagePage(
                  key: const ValueKey(_Page.language),
                  selectedCode: PreferencesScope.of(
                    context,
                  ).locale.languageCode,
                  supportedLanguages: widget.supportedLanguages,
                  onSelected: (code) {
                    PreferencesScope.update(
                      context,
                      (p) => p.copyWith(locale: Locale(code)),
                    );
                    _goToMain();
                  },
                  onBack: _goToMain,
                ),
        ),
      ),
    );
  }

  /// Language page always slides in from the right / out to the right.
  /// Main page always slides in from the left / out to the left.
  /// This naturally handles both forward and backward transitions
  /// without tracking direction explicitly.
  static Widget _slideTransition(Widget child, Animation<double> animation) {
    final isLanguagePage = child.key == const ValueKey(_Page.language);
    final beginOffset = isLanguagePage
        ? const Offset(1, 0)
        : const Offset(-1, 0);
    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
      child: child,
    );
  }
}

/// Reads current [Preferences] from [PreferencesScope] and renders
/// theme, notes view, list density and language controls.
class _MainPage extends StatelessWidget {
  const _MainPage({
    super.key,
    required this.supportedLanguages,
    required this.onLanguageTap,
  });

  final List<SupportedLanguage> supportedLanguages;
  final VoidCallback onLanguageTap;

  @override
  Widget build(BuildContext context) {
    final prefs = PreferencesScope.of(context);
    final l10n = PreferencesLocalizations.of(context)!;
    final selectedLanguage = supportedLanguages.firstWhere(
      (l) => l.code == prefs.locale.languageCode,
      orElse: () => (
        code: prefs.locale.languageCode,
        name: prefs.locale.languageCode.toUpperCase(),
      ),
    );

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.preferences,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Transform.translate(
                  offset: const Offset(Spacing.small, 0),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.mediumLarge),
            _PreferenceRow(
              label: l10n.theme,
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
                onSelectionChanged: (value) => PreferencesScope.update(
                  context,
                  (p) => p.copyWith(themeMode: value.first),
                ),
              ),
            ),
            const SizedBox(height: Spacing.medium),
            _PreferenceRow(
              label: l10n.notesView,
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
                onSelectionChanged: (value) => PreferencesScope.update(
                  context,
                  (p) => p.copyWith(noteViewMode: value.first),
                ),
              ),
            ),
            const SizedBox(height: Spacing.medium),
            _PreferenceRow(
              label: l10n.listDensity,
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
                onSelectionChanged: (value) => PreferencesScope.update(
                  context,
                  (p) => p.copyWith(noteListDensity: value.first),
                ),
              ),
            ),
            const SizedBox(height: Spacing.medium),
            _PreferenceRow(
              label: l10n.language,
              control: TextButton(
                onPressed: onLanguageTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(selectedLanguage.name),
                    const SizedBox(width: Spacing.xSmall),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable list of supported languages with a checkmark
/// on the currently selected one.
class _LanguagePage extends StatelessWidget {
  const _LanguagePage({
    super.key,
    required this.selectedCode,
    required this.supportedLanguages,
    required this.onSelected,
    required this.onBack,
  });

  final String selectedCode;
  final List<SupportedLanguage> supportedLanguages;
  final ValueChanged<String> onSelected;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = PreferencesLocalizations.of(context)!;

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
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: Spacing.small),
                Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: Spacing.mediumLarge),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: Scrollbar(
                thickness: 4,
                radius: const Radius.circular(2),
                child: ListView.builder(
                  itemCount: supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = supportedLanguages[index];
                    final isSelected = lang.code == selectedCode;
                    return ListTile(
                      dense: true,
                      title: Text(
                        lang.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () => onSelected(lang.code),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single row with a label on the left and a control widget on the right.
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
