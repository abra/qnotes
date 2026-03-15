import 'dart:convert';

/// Utility for working with Quill Delta JSON stored in [Note.content].
///
/// [Note.content] can be either:
/// - Legacy plain text (old notes)
/// - Quill Delta JSON: `{"ops": [{"insert": "..."}, ...]}`
abstract final class DeltaUtils {
  /// Returns true if [content] is a valid Quill Delta JSON string.
  static bool isDelta(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is! Map) return false;
      final ops = decoded['ops'];
      return ops is List;
    } catch (_) {
      return false;
    }
  }

  /// Extracts plain text from [content].
  ///
  /// If [content] is a Delta JSON, concatenates all text inserts.
  /// If [content] is plain text, returns it as-is.
  static String toPlainText(String content) {
    if (!isDelta(content)) return content;
    try {
      final decoded = jsonDecode(content) as Map;
      final ops = decoded['ops'] as List;
      final buffer = StringBuffer();
      for (final op in ops) {
        if (op is Map) {
          final insert = op['insert'];
          if (insert is String) buffer.write(insert);
        }
      }
      return buffer.toString().trimRight();
    } catch (_) {
      return content;
    }
  }

  /// Returns true if [content] has no meaningful text or embeds.
  static bool isContentEmpty(String content) {
    if (!isDelta(content)) return content.trim().isEmpty;
    final plain = toPlainText(content).trim();
    if (plain.isNotEmpty) return false;
    // Check for non-text embeds (e.g. images)
    try {
      final decoded = jsonDecode(content) as Map;
      final ops = decoded['ops'] as List;
      return !ops.any((op) => op is Map && op['insert'] is Map);
    } catch (_) {
      return true;
    }
  }

  /// Returns the file path of the first image embed in [content], or null.
  static String? firstImagePath(String content) {
    if (!isDelta(content)) return null;
    try {
      final decoded = jsonDecode(content) as Map;
      final ops = decoded['ops'] as List;
      for (final op in ops) {
        if (op is Map) {
          final insert = op['insert'];
          if (insert is Map && insert.containsKey('image')) {
            final path = insert['image'];
            if (path is String) return path;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Returns all image paths embedded in [content].
  static List<String> allImagePaths(String content) {
    if (!isDelta(content)) return [];
    try {
      final decoded = jsonDecode(content) as Map;
      final ops = decoded['ops'] as List;
      return [
        for (final op in ops)
          if (op is Map)
            if (op['insert'] is Map &&
                (op['insert'] as Map).containsKey('image'))
              (op['insert'] as Map)['image'] as String,
      ];
    } catch (_) {
      return [];
    }
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
