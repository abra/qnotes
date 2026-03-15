part of 'note_details_bloc.dart';

enum NoteDetailsStatus {
  initial,
  loading,
  saving,
  success,
  saved,
  deleted,
  failure,
}

class NoteDetailsState extends Equatable {
  const NoteDetailsState({
    this.status = NoteDetailsStatus.initial,
    this.isNew = true,
    this.note,
    this.title = '',
    this.content = '',
    this.originalContent,
    this.color = NoteColor.none,
    this.isPinned = false,
    this.loadError,
    this.saveError,
  });

  final NoteDetailsStatus status;
  final bool isNew;
  final Note? note;
  final String title;
  final String content;

  /// The content as loaded from the repository, used to detect real changes.
  final String? originalContent;

  final NoteColor color;
  final bool isPinned;
  final Object? loadError;
  final Object? saveError;

  /// Whether the current content is empty (Delta-aware).
  bool get isContentEmpty => DeltaUtils.isContentEmpty(content);

  NoteDetailsState copyWith({
    NoteDetailsStatus? status,
    bool? isNew,
    Note? note,
    String? title,
    String? content,
    String? originalContent,
    NoteColor? color,
    bool? isPinned,
    Object? loadError,
    Object? saveError,
  }) => NoteDetailsState(
    status: status ?? this.status,
    isNew: isNew ?? this.isNew,
    note: note ?? this.note,
    title: title ?? this.title,
    content: content ?? this.content,
    originalContent: originalContent ?? this.originalContent,
    color: color ?? this.color,
    isPinned: isPinned ?? this.isPinned,
    loadError: loadError,
    saveError: saveError,
  );

  @override
  List<Object?> get props => [
    status,
    isNew,
    note,
    title,
    content,
    originalContent,
    color,
    isPinned,
    loadError,
    saveError,
  ];

  @override
  String toString() =>
      'NoteDetailsState(status: $status, isNew: $isNew, '
      'noteId: ${note?.id}, title: "$title", color: $color, isPinned: $isPinned)';
}
