/// Describes a single persisted column (a typed key-value entry in storage).
abstract base class PersistedColumn<T extends Object> {
  const PersistedColumn();

  /// Reads the stored value, returns null if not set.
  Future<T?> read();

  /// Writes [value] to storage.
  Future<void> set(T value);

  /// Removes the stored value.
  Future<void> remove();

  /// Writes [value] if non-null, otherwise removes the entry.
  Future<void> setIfNullRemove(T? value) =>
      value == null ? remove() : set(value);
}
