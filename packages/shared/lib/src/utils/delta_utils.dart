import 'dart:convert';

/// Utility for working with Quill Delta JSON stored in [Note.content].
///
/// [Note.content] can be either:
/// - Legacy plain text (old notes)
/// - Quill Delta JSON: `{"ops": [{"insert": "..."}, ...]}`
abstract final class DeltaUtils {
  /// Extracts the ops list from [content], handling both formats:
  /// - Canonical: `{"ops": [...]}`
  /// - Legacy bare array: `[...]`
  ///
  /// Returns null if [content] is not a recognized Delta format.
  static List<dynamic>? _extractOps(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map) {
        final ops = decoded['ops'];
        if (ops is List) return ops;
      } else if (decoded is List) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  /// Returns true if [content] is a valid Quill Delta JSON string.
  ///
  /// Accepts both canonical `{"ops":[...]}` and legacy bare `[...]` formats.
  static bool isDelta(String content) => _extractOps(content) != null;

  /// Extracts plain text from [content].
  ///
  /// If [content] is a Delta JSON, concatenates all text inserts.
  /// If [content] is plain text, returns it as-is.
  static String toPlainText(String content) {
    final ops = _extractOps(content);
    if (ops == null) return content;
    final buffer = StringBuffer();
    for (final op in ops) {
      if (op is Map) {
        final insert = op['insert'];
        if (insert is String) buffer.write(insert);
      }
    }
    return buffer.toString().trimRight();
  }

  /// Returns true if [content] has no meaningful text or embeds.
  static bool isContentEmpty(String content) {
    final ops = _extractOps(content);
    if (ops == null) return content.trim().isEmpty;
    final plain = toPlainText(content).trim();
    if (plain.isNotEmpty) return false;
    return !ops.any((op) => op is Map && op['insert'] is Map);
  }

  /// Returns the file path of the first image embed in [content], or null.
  static String? firstImagePath(String content) {
    final ops = _extractOps(content);
    if (ops == null) return null;
    for (final op in ops) {
      if (op is Map) {
        final insert = op['insert'];
        if (insert is Map && insert.containsKey('image')) {
          final path = insert['image'];
          if (path is String) return path;
        }
      }
    }
    return null;
  }

  /// Returns all image paths embedded in [content].
  static List<String> allImagePaths(String content) {
    final ops = _extractOps(content);
    if (ops == null) return [];
    return [
      for (final op in ops)
        if (op is Map)
          if (op['insert'] is Map && (op['insert'] as Map).containsKey('image'))
            (op['insert'] as Map)['image'] as String,
    ];
  }

  /// Wraps [plainText] into a minimal Quill Delta JSON string.
  static String fromPlainText(String plainText) {
    final text = plainText.isEmpty ? '\n' : '$plainText\n';
    return jsonEncode({
      'ops': [
        {'insert': text},
      ],
    });
  }
}
