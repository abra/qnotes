import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:preferences_repository/preferences_repository.dart';
import 'package:shared/shared.dart';

import 'l10n/preferences_localizations.dart';

// ---------------------------------------------------------------------------
// Supported languages
// ---------------------------------------------------------------------------

typedef _Language = ({String code, String name});

const _supportedLanguages = <_Language>[
  (code: 'en', name: 'English'),
  (code: 'zh', name: '中文（简体）'),
  (code: 'hi', name: 'हिन्दी'),
  (code: 'es', name: 'Español'),
  (code: 'ar', name: 'العربية'),
  (code: 'fr', name: 'Français'),
  (code: 'ru', name: 'Русский'),
  (code: 'pt', name: 'Português'),
  (code: 'de', name: 'Deutsch'),
  (code: 'ja', name: '日本語'),
];

// ---------------------------------------------------------------------------
// Sheet pages
// ---------------------------------------------------------------------------

enum _Page { main, language }

// ---------------------------------------------------------------------------
// PreferencesBottomSheet
// ---------------------------------------------------------------------------

class PreferencesBottomSheet extends StatefulWidget {
  const PreferencesBottomSheet({super.key, required this.preferencesService});

  final PreferencesService preferencesService;

  @override
  State<PreferencesBottomSheet> createState() => _PreferencesBottomSheetState();
}

class _PreferencesBottomSheetState extends State<PreferencesBottomSheet> {
  _Page _page = _Page.main;

  void _goToLanguage() => setState(() => _page = _Page.language);
  void _goToMain() => setState(() => _page = _Page.main);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Preferences>(
      stream: widget.preferencesService.stream,
      initialData: widget.preferencesService.current,
      builder: (context, snapshot) {
        final prefs = snapshot.data ?? widget.preferencesService.current;

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
                      prefs: prefs,
                      preferencesService: widget.preferencesService,
                      onLanguageTap: _goToLanguage,
                    )
                  : _LanguagePage(
                      key: const ValueKey(_Page.language),
                      selectedCode: prefs.locale.languageCode,
                      onSelected: (code) {
                        widget.preferencesService.update(
                          (p) => p.copyWith(locale: Locale(code)),
                        );
                        _goToMain();
                      },
                      onBack: _goToMain,
                    ),
            ),
          ),
        );
      },
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

// ---------------------------------------------------------------------------
// Main page
// ---------------------------------------------------------------------------

class _MainPage extends StatelessWidget {
  const _MainPage({
    super.key,
    required this.prefs,
    required this.preferencesService,
    required this.onLanguageTap,
  });

  final Preferences prefs;
  final PreferencesService preferencesService;
  final VoidCallback onLanguageTap;

  @override
  Widget build(BuildContext context) {
    final l10n = PreferencesLocalizations.of(context)!;
    final selectedLanguage = _supportedLanguages.firstWhere(
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
            const _DragHandle(),
            Text(
              l10n.preferences,
              style: Theme.of(context).textTheme.titleLarge,
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
                onSelectionChanged: (value) => preferencesService.update(
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
                onSelectionChanged: (value) => preferencesService.update(
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
                onSelectionChanged: (value) => preferencesService.update(
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

// ---------------------------------------------------------------------------
// Language page
// ---------------------------------------------------------------------------

class _LanguagePage extends StatefulWidget {
  const _LanguagePage({
    super.key,
    required this.selectedCode,
    required this.onSelected,
    required this.onBack,
  });

  final String selectedCode;
  final ValueChanged<String> onSelected;
  final VoidCallback onBack;

  @override
  State<_LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<_LanguagePage> {
  var _query = '';

  List<_Language> get _filtered {
    if (_query.isEmpty) return _supportedLanguages;
    final q = _query.toLowerCase();
    return _supportedLanguages
        .where((l) => l.name.toLowerCase().contains(q) || l.code.contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = PreferencesLocalizations.of(context)!;
    final filtered = _filtered;

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
            const _DragHandle(),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
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
            TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: Spacing.small),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final lang = filtered[index];
                  final isSelected = lang.code == widget.selectedCode;
                  return ListTile(
                    dense: true,
                    title: Text(lang.name),
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => widget.onSelected(lang.code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        margin: const EdgeInsets.only(bottom: Spacing.mediumLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
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
