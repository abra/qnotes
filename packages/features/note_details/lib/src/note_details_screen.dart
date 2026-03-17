import 'dart:async';
import 'dart:convert';

import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_files/image_files.dart';
import 'package:note_repository/note_repository.dart';
import 'package:shared/shared.dart';
import 'package:toast_service/toast_service.dart';

import 'l10n/note_details_localizations.dart';
import 'note_details_bloc.dart';

part 'note_color_picker.dart';

enum _SecondaryPanelMode { formatting, colors }

// Parses note content into a Quill ops list.
// Handles canonical {"ops":[...]} Delta, legacy bare [...] array, and plain text.
List<dynamic> _opsFromContent(String content) {
  try {
    final decoded = jsonDecode(content);
    if (decoded is Map) return decoded['ops'] as List<dynamic>;
    if (decoded is List) return decoded; // legacy format (bare array)
  } catch (_) {}
  return [
    {'insert': '${content.isEmpty ? '' : content}\n'},
  ];
}

class NoteDetailsScreen extends StatelessWidget {
  const NoteDetailsScreen({
    super.key,
    required this.noteRepository,
    required this.imageFiles,
    this.noteId,
  });

  final NoteRepository noteRepository;
  final ImageFiles imageFiles;
  final String? noteId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteDetailsBloc>(
      create: (_) => NoteDetailsBloc(
        noteRepository: noteRepository,
        imageFiles: imageFiles,
        isNew: noteId == null,
      )..add(NoteDetailsStarted(noteId: noteId)),
      child: const NoteDetailsView(),
    );
  }
}

@visibleForTesting
class NoteDetailsView extends StatefulWidget {
  const NoteDetailsView({super.key});

  @override
  State<NoteDetailsView> createState() => _NoteDetailsViewState();
}

class _NoteDetailsViewState extends State<NoteDetailsView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;
  late QuillController _quillController;
  late final FocusNode _quillFocusNode;
  late final ScrollController _quillScrollController;
  late final AnimationController _toolbarAnimController;
  late final Animation<double> _toolbarAnimation;
  StreamSubscription<DocChange>? _changesSub;
  bool _contentInitialized = false;
  _SecondaryPanelMode _activePanel = _SecondaryPanelMode.formatting;
  bool _isPanelOpen = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _quillController = QuillController.basic();
    _quillFocusNode = FocusNode();
    _quillScrollController = ScrollController();
    _toolbarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _toolbarAnimation = CurvedAnimation(
      parent: _toolbarAnimController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _subscribeToChanges();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _changesSub?.cancel();
    _quillController.dispose();
    _quillFocusNode.dispose();
    _quillScrollController.dispose();
    _toolbarAnimController.dispose();
    super.dispose();
  }

  void _subscribeToChanges() {
    _changesSub?.cancel();
    _changesSub = _quillController.changes.listen((change) {
      if (!mounted) return;
      if (change.source != ChangeSource.local) return;
      final json = jsonEncode({
        'ops': _quillController.document.toDelta().toJson(),
      });
      context.read<NoteDetailsBloc>().add(NoteDetailsContentChanged(json));
    });
  }

  QuillController _controllerFromContent(String content) {
    return QuillController(
      document: Document.fromJson(_opsFromContent(content)),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void _saveAndPop(BuildContext context) {
    final bloc = context.read<NoteDetailsBloc>();
    final state = bloc.state;

    if (state.isContentEmpty && state.title.trim().isEmpty) {
      if (!state.isNew) {
        bloc.add(NoteDetailsDeleteRequested());
      } else {
        Navigator.of(context).pop<Note?>(null);
      }
      return;
    }

    // For existing notes, skip save if nothing actually changed
    if (!state.isNew && state.note != null) {
      final note = state.note!;
      final unchanged =
          state.title.trim() == (note.title ?? '') &&
          state.content == (state.originalContent ?? note.content) &&
          state.color == note.color &&
          state.isPinned == note.isPinned;
      if (unchanged) {
        Navigator.of(context).pop<Note?>(note);
        return;
      }
    }
    bloc.add(NoteDetailsSaved());
  }

  DefaultStyles _buildEditorStyles(BuildContext context) {
    const noH = HorizontalSpacing(0, 0);
    final bodyLarge = Theme.of(context).textTheme.bodyLarge!;
    final body = bodyLarge.copyWith(decoration: TextDecoration.none);
    final bodyWithHeight = body.copyWith(height: 1.5);
    final hintColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.38);
    return DefaultStyles(
      paragraph: DefaultTextBlockStyle(
        bodyWithHeight,
        noH,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      ),
      placeHolder: DefaultTextBlockStyle(
        bodyWithHeight.copyWith(color: hintColor),
        noH,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      ),
      leading: DefaultTextBlockStyle(
        body,
        noH,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      ),
      lists: DefaultListBlockStyle(
        body,
        noH,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
        null,
      ),
      bold: bodyLarge.copyWith(fontWeight: FontWeight.bold),
      italic: bodyLarge.copyWith(fontStyle: FontStyle.italic),
      underline: bodyLarge.copyWith(decoration: TextDecoration.underline),
      strikeThrough: bodyLarge.copyWith(
        decoration: TextDecoration.lineThrough,
      ),
    );
  }

  void _togglePanel(_SecondaryPanelMode mode) {
    setState(() {
      if (_isPanelOpen && _activePanel == mode) {
        _isPanelOpen = false;
        _toolbarAnimController.reverse();
      } else {
        _activePanel = mode;
        if (!_isPanelOpen) {
          _isPanelOpen = true;
          _toolbarAnimController.forward();
        }
      }
    });
  }

  static const double _toolbarClearance = 60;

  // Secondary panel: 32px buttons + 8*2 padding + 8 gap below = 56px
  static const double _secondaryPanelHeight = 56;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteDetailsBloc, NoteDetailsState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      buildWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.color != curr.color ||
          prev.isPinned != curr.isPinned ||
          prev.isNew != curr.isNew,
      listener: (context, state) {
        final l10n = NoteDetailsLocalizations.of(context)!;

        if (state.status == NoteDetailsStatus.success) {
          _titleController.text = state.title;
          if (!_contentInitialized) {
            _contentInitialized = true;
            final newController = _controllerFromContent(state.content);
            final oldController = _quillController;
            _changesSub?.cancel();
            _quillController = newController;
            _subscribeToChanges();
            // Defer disposal: the old QuillEditor is still in the tree and
            // holds a ChangeNotifier listener on oldController. Disposing it
            // synchronously triggers a '_count == 0' assertion in debug mode.
            // Disposing after the frame ensures the widget has rebuilt first.
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => oldController.dispose(),
            );
          }
        }

        if (state.status == NoteDetailsStatus.saved) {
          Navigator.of(context).pop<Note?>(state.note);
        }

        if (state.status == NoteDetailsStatus.deleted) {
          Navigator.of(context).pop<Note?>(null);
        }

        if (state.status == NoteDetailsStatus.failure) {
          final isNotFound = state.loadError is NoteNotFoundException;
          showToast(
            context,
            type: NotificationType.error,
            message: isNotFound
                ? l10n.noteNotFound
                : state.saveError != null
                ? l10n.noteSaveFailed
                : l10n.noteLoadFailed,
          );
        }
      },
      builder: (context, state) {
        final l10n = NoteDetailsLocalizations.of(context)!;
        final brightness = Theme.of(context).brightness;
        final hasColor = state.color != NoteColor.none;
        final appBarColor = hasColor
            ? state.color.forBrightness(brightness)
            : null;
        final appBarForeground = hasColor
            ? state.color.onColor
            : Theme.of(context).colorScheme.onSurface;
        final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _saveAndPop(context);
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: appBarColor,
              foregroundColor: appBarForeground,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _saveAndPop(context),
              ),
              centerTitle: true,
              title: Text(
                state.isNew ? l10n.newNote : l10n.editNote,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: appBarForeground,
                ),
              ),
              actions: [
                if (state.isPinned)
                  Padding(
                    padding: const EdgeInsets.only(
                      right: Spacing.mediumLarge,
                    ),
                    child: Icon(
                      Icons.push_pin,
                      color: appBarForeground.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              top: false,
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.mediumLarge,
                          Spacing.medium,
                          Spacing.mediumLarge,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: TextField(
                            controller: _titleController,
                            onChanged: (v) => context
                                .read<NoteDetailsBloc>()
                                .add(NoteDetailsTitleChanged(v)),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: l10n.titleHint,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: Spacing.xSmall,
                              ),
                            ),
                            maxLines: null,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: AnimatedBuilder(
                          animation: _toolbarAnimation,
                          builder: (context, child) => Padding(
                            padding: EdgeInsets.fromLTRB(
                              Spacing.mediumLarge,
                              Spacing.small,
                              Spacing.mediumLarge,
                              _toolbarClearance +
                                  _toolbarAnimation.value *
                                      _secondaryPanelHeight,
                            ),
                            child: child,
                          ),
                          child: QuillEditor(
                            controller: _quillController,
                            focusNode: _quillFocusNode,
                            scrollController: _quillScrollController,
                            config: QuillEditorConfig(
                              placeholder: l10n.contentHint,
                              scrollable: false,
                              expands: false,
                              padding: EdgeInsets.zero,
                              autoFocus: false,
                              customStyles: _buildEditorStyles(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _toolbarAnimation,
                        builder: (context, _) => Container(
                          height:
                              _toolbarClearance +
                              _toolbarAnimation.value * _secondaryPanelHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                scaffoldBg.withValues(alpha: 0),
                                scaffoldBg,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: Spacing.mediumLarge,
                    right: Spacing.mediumLarge,
                    bottom: Spacing.mediumLarge,
                    child: _NoteToolbar(
                      key: ObjectKey(_quillController),
                      controller: _quillController,
                      animation: _toolbarAnimation,
                      activePanel: _activePanel,
                      isSecondaryOpen: _isPanelOpen,
                      isPinned: state.isPinned,
                      noteColor: state.color,
                      onToggleFormatting: () =>
                          _togglePanel(_SecondaryPanelMode.formatting),
                      onToggleColors: () =>
                          _togglePanel(_SecondaryPanelMode.colors),
                      onImagePressed: () {},
                      onMicPressed: () {},
                      onPinToggled: () => context.read<NoteDetailsBloc>().add(
                        NoteDetailsPinToggled(),
                      ),
                      onColorSelected: (color) =>
                          context.read<NoteDetailsBloc>().add(
                            NoteDetailsColorChanged(color),
                          ),
                      onNewLine: () {
                        final offset = _quillController.selection.extentOffset;
                        _quillController.replaceText(
                          offset,
                          0,
                          '\n',
                          TextSelection.collapsed(offset: offset + 1),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

const _toolbarRadius = BorderRadius.all(Radius.circular(AppRadius.large));

const _toolbarShadows = [
  BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 20,
    offset: Offset(0, -4),
  ),
  BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 20,
    offset: Offset(0, 4),
  ),
  BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 6,
    offset: Offset(0, -1),
  ),
  BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 6,
    offset: Offset(0, 1),
  ),
];

const _toolbarButtonStyle = ButtonStyle(
  fixedSize: WidgetStatePropertyAll(Size(32, 32)),
  padding: WidgetStatePropertyAll(EdgeInsets.zero),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
);

class _NoteToolbar extends StatelessWidget {
  const _NoteToolbar({
    super.key,
    required this.controller,
    required this.animation,
    required this.activePanel,
    required this.isSecondaryOpen,
    required this.isPinned,
    required this.noteColor,
    required this.onToggleFormatting,
    required this.onToggleColors,
    required this.onImagePressed,
    required this.onMicPressed,
    required this.onPinToggled,
    required this.onColorSelected,
    required this.onNewLine,
  });

  final QuillController controller;
  final Animation<double> animation;
  final _SecondaryPanelMode activePanel;
  final bool isSecondaryOpen;
  final bool isPinned;
  final NoteColor noteColor;
  final VoidCallback onToggleFormatting;
  final VoidCallback onToggleColors;
  final VoidCallback onImagePressed;
  final VoidCallback onMicPressed;
  final VoidCallback onPinToggled;
  final ValueChanged<NoteColor> onColorSelected;
  final VoidCallback onNewLine;

  Widget _buildSecondaryContent(BuildContext context) => switch (activePanel) {
    _SecondaryPanelMode.formatting => _FormattingPanel(
      controller: controller,
    ),
    _SecondaryPanelMode.colors => _InlineColorPanel(
      selected: noteColor,
      onSelected: onColorSelected,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Align(
            alignment: Alignment.topCenter,
            heightFactor: animation.value,
            child: child,
          ),
          child: FadeTransition(
            opacity: animation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: Spacing.small),
              child: _buildSecondaryContent(context),
            ),
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0x00000000),
            borderRadius: _toolbarRadius,
            boxShadow: _toolbarShadows,
          ),
          child: ClipRRect(
            borderRadius: _toolbarRadius,
            child: ColoredBox(
              color: colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.small),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.mic_none,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      style: _toolbarButtonStyle,
                      onPressed: onMicPressed,
                    ),
                    const SizedBox(width: Spacing.xSmall),
                    ListenableBuilder(
                      listenable: controller,
                      builder: (context, _) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.undo,
                              color: controller.hasUndo
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.3,
                                    ),
                            ),
                            style: _toolbarButtonStyle,
                            onPressed: controller.hasUndo
                                ? controller.undo
                                : null,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.redo,
                              color: controller.hasRedo
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.3,
                                    ),
                            ),
                            style: _toolbarButtonStyle,
                            onPressed: controller.hasRedo
                                ? controller.redo
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Spacing.xSmall),
                    IconButton(
                      icon: Icon(
                        Icons.text_format,
                        color:
                            isSecondaryOpen &&
                                activePanel == _SecondaryPanelMode.formatting
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      style: _toolbarButtonStyle,
                      onPressed: onToggleFormatting,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.image_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      style: _toolbarButtonStyle,
                      onPressed: onImagePressed,
                    ),
                    IconButton(
                      style: _toolbarButtonStyle,
                      icon: Container(
                        width: IconSize.medium,
                        height: IconSize.medium,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: noteColor == NoteColor.none
                              ? colorScheme.surfaceContainerHighest
                              : noteColor.forBrightness(brightness),
                          border:
                              isSecondaryOpen &&
                                  activePanel == _SecondaryPanelMode.colors
                              ? Border.all(
                                  color: colorScheme.primary,
                                  width: 2.5,
                                )
                              : noteColor == NoteColor.none
                              ? Border.all(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: noteColor == NoteColor.none
                            ? Icon(
                                Icons.palette_outlined,
                                size: IconSize.xSmall,
                                color: colorScheme.onSurfaceVariant,
                              )
                            : null,
                      ),
                      onPressed: onToggleColors,
                    ),
                    IconButton(
                      icon: Icon(
                        isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: isPinned
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      style: _toolbarButtonStyle,
                      onPressed: onPinToggled,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.keyboard_return,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      style: _toolbarButtonStyle,
                      onPressed: onNewLine,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormattingPanel extends StatelessWidget {
  const _FormattingPanel({
    required this.controller,
  });

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0x00000000),
        borderRadius: _toolbarRadius,
        boxShadow: _toolbarShadows,
      ),
      child: ClipRRect(
        borderRadius: _toolbarRadius,
        child: ColoredBox(
          color: colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.small),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: QuillSimpleToolbar(
                      controller: controller,
                      config: QuillSimpleToolbarConfig(
                        multiRowsDisplay: false,
                        toolbarSize: 32,
                        toolbarSectionSpacing: 0,
                        color: Colors.transparent,
                        buttonOptions: QuillSimpleToolbarButtonOptions(
                          base: QuillToolbarBaseButtonOptions(
                            iconTheme: QuillIconTheme(
                              iconButtonUnselectedData: IconButtonData(
                                style: _toolbarButtonStyle,
                                color: colorScheme.onSurface,
                              ),
                              iconButtonSelectedData: IconButtonData(
                                style: _toolbarButtonStyle.copyWith(
                                  backgroundColor: const WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),
                                ),
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        showBoldButton: true,
                        showItalicButton: true,
                        showUnderLineButton: true,
                        showListNumbers: true,
                        showListBullets: true,
                        showListCheck: true,
                        showUndo: false,
                        showRedo: false,
                        showDividers: false,
                        showFontFamily: false,
                        showFontSize: false,
                        showStrikeThrough: false,
                        showInlineCode: false,
                        showHeaderStyle: false,
                        showCodeBlock: false,
                        showQuote: false,
                        showIndent: false,
                        showLink: false,
                        showSearchButton: false,
                        showColorButton: false,
                        showBackgroundColorButton: false,
                        showClearFormat: true,
                        showSuperscript: false,
                        showSubscript: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
