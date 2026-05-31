import 'package:flutter/services.dart';
import '../core/morphix_state.dart';

/// Handles tap logic, press scale, and haptic feedback.
/// Separated from [MorphixButton] to keep state machine clean.
class MorphixTapHandler {
  MorphixTapHandler._();

  /// Called on finger down — triggers press scale and haptic.
  static void onTapDown({
    required MorphixState state,
    required bool haptic,
    required VoidCallback onPressDown,
  }) {
    if (state != MorphixState.idle) return;
    onPressDown();
    if (haptic) HapticFeedback.lightImpact();
  }

  /// Called on finger up or cancel — releases press scale.
  static void onTapUp({required VoidCallback onPressUp}) {
    onPressUp();
  }

  /// Called on tap cancel — releases press scale.
  static void onTapCancel({required VoidCallback onPressUp}) {
    onPressUp();
  }

  /// Fires success haptic — double tap pattern.
  static void successHaptic() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Fires error haptic — single hard buzz.
  static void errorHaptic() {
    HapticFeedback.heavyImpact();
  }
}
