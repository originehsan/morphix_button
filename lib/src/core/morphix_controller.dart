import 'package:flutter/foundation.dart';

import 'morphix_state.dart';

/// Controls a [Morphix] button externally.
/// Compatible with Riverpod, Bloc, GetX, or any state manager.
/// Always call [dispose] when done.
class MorphixController extends ChangeNotifier {
  MorphixState _state = MorphixState.idle;
  double _progress = 0.0;
  bool _disposed = false;

  /// Current button state.
  MorphixState get state => _state;

  /// Current progress value — only meaningful in [MorphixState.progress].
  double get progress => _progress;

  /// Whether this controller has been disposed.
  bool get isDisposed => _disposed;

  // ── State API ──────────────────────────────────────────────────────

  void loading() => _set(MorphixState.loading);
  void success() => _set(MorphixState.success);
  void error() => _set(MorphixState.error);
  void reset() => _set(MorphixState.idle);
  void disable() => _set(MorphixState.disabled);
  void enable() => _set(MorphixState.idle);

  /// Sets determinate progress [0.0 → 1.0].
  /// Automatically transitions to [MorphixState.progress] on first call.
  /// Call [success] or [error] when done.
  void setProgress(double value) {
    if (_disposed) return;

    // Clamp silently — no throw, matches Flutter's own conventions
    _progress = value.clamp(0.0, 1.0);

    // Auto-transition to progress state on first call
    if (_state != MorphixState.progress) {
      _state = MorphixState.progress;
    }

    notifyListeners();
  }

  // ── Internal ───────────────────────────────────────────────────────

  void _set(MorphixState next) {
    if (_disposed) return;
    if (_state == next) return;
    _state = next;

    // Reset progress when leaving progress state
    if (next != MorphixState.progress) _progress = 0.0;

    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
