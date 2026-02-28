/// Extension methods on [String].
extension StringExtension on String {
  /// Returns the first [length] characters of this string.
  ///
  /// If [length] is negative the original string is returned.
  /// If [length] is zero an empty string is returned.
  String limit(int length) => length < 0
      ? this
      : (length == 0
            ? ''
            : (length < this.length ? substring(0, length) : this));
}
