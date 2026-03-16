/// Thrown when an image operation fails.
class ImageFilesException implements Exception {
  ImageFilesException(this.message, [this.cause, this.stackTrace]);

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buf = StringBuffer('ImageFilesException: $message');
    if (cause != null) buf.write('\nCause: $cause');
    return buf.toString();
  }
}
