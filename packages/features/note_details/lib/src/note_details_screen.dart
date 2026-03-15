import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_repository/note_repository.dart';
import 'package:shared/shared.dart';
import 'package:toastification/toastification.dart';

import 'l10n/note_details_localizations.dart';
import 'note_details_bloc.dart';

part 'note_color_picker.dart';

class NoteDetailsScreen extends StatelessWidget {
  const NoteDetailsScreen({
    super.key,
    required this.noteRepository,
    this.noteId,
  });

  final NoteRepository noteRepository;
  final String? noteId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteDetailsBloc>(
      create: (_) => NoteDetailsBloc(
        noteRepository: noteRepository,
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
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveAndPop(BuildContext context) {
    final bloc = context.read<NoteDetailsBloc>();
    final isEmpty =
        bloc.state.content.trim().isEmpty && bloc.state.title.trim().isEmpty;

    if (isEmpty) {
      if (!bloc.state.isNew) {
        bloc.add(NoteDetailsDeleteRequested());
      } else {
        Navigator.of(context).pop<Note?>(null);
      }
      return;
    }

    // For existing notes, skip save if nothing actually changed
    if (!bloc.state.isNew && bloc.state.note != null) {
      final note = bloc.state.note!;
      final unchanged =
          bloc.state.title.trim() == (note.title ?? '') &&
          bloc.state.content.trim() == note.content &&
          bloc.state.color == note.color &&
          bloc.state.isPinned == note.isPinned;
      if (unchanged) {
        Navigator.of(context).pop<Note?>(note);
        return;
      }
    }
    bloc.add(NoteDetailsSaved());
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
          _contentController.text = state.content;
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
        final textColor = hasColor
            ? CatppuccinLatte.text
            : Theme.of(context).colorScheme.onSurface;
        final hintColor = textColor.withValues(alpha: 0.45);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _saveAndPop(context);
          },
          child: Scaffold(
            backgroundColor: hasColor
                ? state.color.forBrightness(brightness)
                : null,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.mediumLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: textColor),
                          onPressed: () => _saveAndPop(context),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        Expanded(
                          child: Text(
                            state.isNew ? l10n.newNote : l10n.editNote,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(color: textColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            state.isPinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                            color: textColor,
                          ),
                          onPressed: () => context.read<NoteDetailsBloc>().add(
                            NoteDetailsPinToggled(),
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.small),
                    // Title row with color dot
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _titleController,
                            onChanged: (v) => context
                                .read<NoteDetailsBloc>()
                                .add(NoteDetailsTitleChanged(v)),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                            decoration: InputDecoration(
                              hintText: l10n.titleHint,
                              hintStyle: TextStyle(color: hintColor),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(width: Spacing.small),
                        IconButton(
                          icon: Icon(
                            state.color == NoteColor.none
                                ? Icons.palette_outlined
                                : Icons.palette,
                            color: textColor,
                          ),
                          onPressed: () =>
                              _showColorPicker(context, state.color),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.small),
                    // Content
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        onChanged: (v) => context.read<NoteDetailsBloc>().add(
                          NoteDetailsContentChanged(v),
                        ),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: textColor),
                        decoration: InputDecoration(
                          hintText: l10n.contentHint,
                          hintStyle: TextStyle(color: hintColor),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
