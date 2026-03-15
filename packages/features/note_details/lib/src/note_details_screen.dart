import 'dart:async';
import 'dart:convert';

import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_service/image_service.dart';
import 'package:note_repository/note_repository.dart';
import 'package:shared/shared.dart';
import 'package:toastification/toastification.dart';

import 'l10n/note_details_localizations.dart';
import 'note_details_bloc.dart';

part 'note_color_picker.dart';

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
    required this.imageService,
    this.noteId,
  });

  final NoteRepository noteRepository;
  final ImageService imageService;
  final String? noteId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteDetailsBloc>(
      create: (_) => NoteDetailsBloc(
        noteRepository: noteRepository,
        imageService: imageService,
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

class _NoteDetailsViewState extends State<NoteDetailsView> {
  late final TextEditingController _titleController;
  late QuillController _quillController;
  late final FocusNode _quillFocusNode;
  late final ScrollController _quillScrollController;
  StreamSubscription<DocChange>? _changesSub;
  bool _contentInitialized = false;
  bool _secondaryPanelVisible = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _quillController = QuillController.basic();
    _quillFocusNode = FocusNode();
    _quillScrollController = ScrollController();
    _subscribeToChanges();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _changesSub?.cancel();
    _quillController.dispose();
    _quillFocusNode.dispose();
    _quillScrollController.dispose();
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

  void _showColorPicker(BuildContext context, NoteColor selected) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _NoteColorPicker(
        selected: selected,
        onSelected: (color) =>
            context.read<NoteDetailsBloc>().add(NoteDetailsColorChanged(color)),
        onDismiss: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

  static const double _toolbarClearance = 60;
  static const double _toolbarClearanceExpanded = 128;

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
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            title: Text(
              isNotFound
                  ? l10n.noteNotFound
                  : state.saveError != null
                  ? l10n.noteSaveFailed
                  : l10n.noteLoadFailed,
            ),
            autoCloseDuration: const Duration(seconds: 3),
            alignment: Alignment.topCenter,
            animationBuilder: (context, animation, alignment, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
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
                          Spacing.small,
                          Spacing.mediumLarge,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: TextField(
                            controller: _titleController,
                            onChanged: (v) =>
                                context.read<NoteDetailsBloc>().add(
                                  NoteDetailsTitleChanged(v),
                                ),
                            style:
                                Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            decoration: InputDecoration(
                              hintText: l10n.titleHint,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: null,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            Spacing.mediumLarge,
                            Spacing.small,
                            Spacing.mediumLarge,
                            _secondaryPanelVisible
                                ? _toolbarClearanceExpanded
                                : _toolbarClearance,
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        height: _secondaryPanelVisible
                            ? _toolbarClearanceExpanded
                            : _toolbarClearance,
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
                  Positioned(
                    left: Spacing.mediumLarge,
                    right: Spacing.mediumLarge,
                    bottom: Spacing.mediumLarge,
                    child: _QuillToolbar(
                      key: ObjectKey(_quillController),
                      controller: _quillController,
                      isPinned: state.isPinned,
                      noteColor: state.color,
                      isSecondaryVisible: _secondaryPanelVisible,
                      onToggleSecondary: () => setState(
                        () => _secondaryPanelVisible = !_secondaryPanelVisible,
                      ),
                      onPinToggled: () => context.read<NoteDetailsBloc>().add(
                        NoteDetailsPinToggled(),
                      ),
                      onColorPressed: () =>
                          _showColorPicker(context, state.color),
                      onImagePressed: () {},
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

class _QuillToolbar extends StatefulWidget {
  const _QuillToolbar({
    super.key,
    required this.controller,
    required this.isPinned,
    required this.noteColor,
    required this.isSecondaryVisible,
    required this.onToggleSecondary,
    required this.onPinToggled,
    required this.onColorPressed,
    required this.onImagePressed,
  });

  final QuillController controller;
  final bool isPinned;
  final NoteColor noteColor;
  final bool isSecondaryVisible;
  final VoidCallback onToggleSecondary;
  final VoidCallback onPinToggled;
  final VoidCallback onColorPressed;
  final VoidCallback onImagePressed;

  @override
  State<_QuillToolbar> createState() => _QuillToolbarState();
}

class _QuillToolbarState extends State<_QuillToolbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isSecondaryVisible ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void didUpdateWidget(_QuillToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSecondaryVisible != oldWidget.isSecondaryVisible) {
      if (widget.isSecondaryVisible) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => Align(
            alignment: Alignment.topCenter,
            heightFactor: _animation.value,
            child: child,
          ),
          child: FadeTransition(
            opacity: _animation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: Spacing.small),
              child: _SecondaryToolbar(
                isPinned: widget.isPinned,
                noteColor: widget.noteColor,
                onPinToggled: widget.onPinToggled,
                onColorPressed: widget.onColorPressed,
                onImagePressed: widget.onImagePressed,
              ),
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
                    Expanded(
                      child: QuillSimpleToolbar(
                        controller: widget.controller,
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
                                    backgroundColor:
                                        const WidgetStatePropertyAll(
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
                          showUndo: true,
                          showRedo: true,
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
                          showClearFormat: false,
                          showSuperscript: false,
                          showSubscript: false,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 28,
                      child: VerticalDivider(
                        width: Spacing.medium,
                        thickness: 0.5,
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: widget.isSecondaryVisible
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      style: _toolbarButtonStyle,
                      onPressed: widget.onToggleSecondary,
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

class _SecondaryToolbar extends StatelessWidget {
  const _SecondaryToolbar({
    required this.isPinned,
    required this.noteColor,
    required this.onPinToggled,
    required this.onColorPressed,
    required this.onImagePressed,
  });

  final bool isPinned;
  final NoteColor noteColor;
  final VoidCallback onPinToggled;
  final VoidCallback onColorPressed;
  final VoidCallback onImagePressed;

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
                IconButton(
                  icon: Icon(
                    noteColor == NoteColor.none
                        ? Icons.palette_outlined
                        : Icons.palette,
                    color: noteColor == NoteColor.none
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.primary,
                  ),
                  style: _toolbarButtonStyle,
                  onPressed: onColorPressed,
                ),
                IconButton(
                  icon: Icon(
                    Icons.image_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  style: _toolbarButtonStyle,
                  onPressed: onImagePressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
