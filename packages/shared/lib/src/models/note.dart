import 'package:equatable/equatable.dart' show Equatable;
import 'package:shared/src/models/note_color.dart';

/// A single note entity.
final class Note extends Equatable {
  const Note({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.title,
    this.isPinned = false,
    this.color = NoteColor.none,
  });

  final String id;
  final String? title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final NoteColor color;

  static const _absent = Object();

  Note copyWith({
    Object? title = _absent,
    String? content,
    DateTime? updatedAt,
    bool? isPinned,
    NoteColor? color,
  }) => Note(
    id: id,
    title: title == _absent ? this.title : title as String?,
    content: content ?? this.content,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isPinned: isPinned ?? this.isPinned,
    color: color ?? this.color,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    createdAt,
    updatedAt,
    isPinned,
    color,
  ];
}
