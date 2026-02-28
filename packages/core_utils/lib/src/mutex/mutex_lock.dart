import 'dart:async';
import 'dart:collection';

/// A simple mutex using a queue of completers.
///
/// Ensures only one task executes a critical section at a time.
class MutexLock {
  MutexLock();

  final _queue = DoubleLinkedQueue<Completer<void>>();

  /// Locks the mutex. Returns a future that completes when the lock is acquired.
  Future<void> lock() {
    final previous = _queue.lastOrNull?.future ?? Future<void>.value();
    _queue.add(Completer<void>.sync());
    return previous;
  }

  /// Unlocks the mutex, allowing the next waiting task to proceed.
  void unlock() {
    if (_queue.isEmpty) {
      assert(false, 'Mutex unlock called when no tasks are waiting.');
      return;
    }

    final completer = _queue.removeFirst();

    if (completer.isCompleted) {
      assert(false, 'Mutex unlock called when the completer is already completed.');
      return;
    }

    completer.complete();
  }

  /// Runs [fn] exclusively — waits for the lock, runs [fn], then unlocks.
  Future<T> runLocked<T>(FutureOr<T> Function() fn) async {
    await lock();
    try {
      return await fn();
    } finally {
      unlock();
    }
  }
}
