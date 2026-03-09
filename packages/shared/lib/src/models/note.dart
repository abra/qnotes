import 'package:equatable/equatable.dart';
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

  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    bool? isPinned,
    NoteColor? color,
  }) => Note(
    id: id,
    title: title ?? this.title,
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
