/// Every possible state of a [Morphix] button.
/// No boolean flags — the button is always in exactly one state.
enum MorphixState {
  /// Ready to be tapped.
  idle,

  /// Async operation in progress — indeterminate spinner shown.
  loading,

  /// Determinate progress — arc fills based on [MorphixController.progress].
  progress,

  /// Operation completed successfully — checkmark draws, particles burst.
  success,

  /// Operation failed — button shakes then resets to idle.
  error,

  /// Explicitly disabled — taps are ignored.
  disabled,
}
