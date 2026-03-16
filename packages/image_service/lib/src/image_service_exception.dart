/// Thrown when an image operation fails.
class ImageServiceException implements Exception {
  ImageServiceException(this.message, [this.cause, this.stackTrace]);

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buf = StringBuffer('ImageServiceException: $message');
    if (cause != null) buf.write('\nCause: $cause');
    return buf.toString();
  }
}
