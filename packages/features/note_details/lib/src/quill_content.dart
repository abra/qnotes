import 'dart:convert';

/// Parses a stored note content string into a Quill ops list.
///
/// Handles three formats that may exist in the database:
/// - Canonical Delta:  `{"ops": [{"insert": "…"}, …]}`
/// - Legacy bare array: `[{"insert": "…"}, …]`
/// - Plain text: any non-JSON string (wrapped in a single insert op)
List<dynamic> opsFromContent(String content) {
  try {
    final decoded = jsonDecode(content);
    if (decoded is Map) return decoded['ops'] as List<dynamic>;
    if (decoded is List) return decoded; // legacy bare-array format
  } catch (_) {}
  return [
    {'insert': '$content\n'},
  ];
}
