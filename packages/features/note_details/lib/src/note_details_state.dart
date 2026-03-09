part of 'note_details_bloc.dart';

enum NoteDetailsStatus { initial, loading, saving, success, saved, failure }

class NoteDetailsState extends Equatable {
  const NoteDetailsState({
    this.status = NoteDetailsStatus.initial,
    this.isNew = true,
    this.note,
    this.title = '',
    this.content = '',
    this.color = NoteColor.none,
    this.isPinned = false,
  });

  final NoteDetailsStatus status;
  final bool isNew;
  final Note? note;
  final String title;
  final String content;
  final NoteColor color;
  final bool isPinned;

  NoteDetailsState copyWith({
    NoteDetailsStatus? status,
    bool? isNew,
    Note? note,
    String? title,
    String? content,
    NoteColor? color,
    bool? isPinned,
  }) => NoteDetailsState(
    status: status ?? this.status,
    isNew: isNew ?? this.isNew,
    note: note ?? this.note,
    title: title ?? this.title,
    content: content ?? this.content,
    color: color ?? this.color,
    isPinned: isPinned ?? this.isPinned,
  );

  @override
  List<Object?> get props => [
    status,
    isNew,
    note,
    title,
    content,
    color,
    isPinned,
  ];
}
