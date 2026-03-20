part of 'note_details_bloc.dart';

const Object _kNoInsertedImage = Object();

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
    this.imageInsertError,
    this.insertedImagePath,
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

  /// Set to the caught exception when image copy fails in [NoteDetailsImageInserted].
  /// Each new failure produces a distinct object so the listener always fires.
  final Object? imageInsertError;

  /// Permanent path of an image just saved by the BLoC, consumed once by the
  /// view to insert the embed into the Quill editor. Cleared on next content
  /// change.
  final String? insertedImagePath;

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
    Object? imageInsertError,
    Object? insertedImagePath = _kNoInsertedImage,
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
    imageInsertError: imageInsertError ?? this.imageInsertError,
    insertedImagePath: identical(insertedImagePath, _kNoInsertedImage)
        ? this.insertedImagePath
        : insertedImagePath as String?,
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
    imageInsertError,
    insertedImagePath,
  ];

  @override
  String toString() =>
      'NoteDetailsState(status: $status, isNew: $isNew, '
      'noteId: ${note?.id}, title: "$title", color: $color, isPinned: $isPinned)';
}
