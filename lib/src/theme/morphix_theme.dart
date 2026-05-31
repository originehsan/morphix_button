import 'package:flutter/material.dart';

import '../core/morphix_state.dart';
import '../model/morphix_style.dart';

/// Resolves colors for every [MorphixState] × [MorphixStyle] × brightness.
/// Pure static methods — no state, no side effects.
class MorphixTheme {
  MorphixTheme._();

  // ── Default state colors ───────────────────────────────────────────

  static const Color defaultSuccess = Color(0xFF22C55E);
  static const Color defaultError = Color(0xFFEF4444);

  // ── Background ─────────────────────────────────────────────────────

  static Color background({
    required MorphixState state,
    required MorphixStyle style,
    required Color base,
    required bool isDark,
    Color? successColor,
    Color? errorColor,
  }) {
    final success = successColor ?? defaultSuccess;
    final error = errorColor ?? defaultError;

    if (state == MorphixState.success) return success;
    if (state == MorphixState.error) return error;
    if (state == MorphixState.disabled) {
      return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    }

    return switch (style) {
      MorphixStyle.filled => base,
      MorphixStyle.outlined => Colors.transparent,
      MorphixStyle.neon =>
        isDark ? const Color(0xFF060B14) : const Color(0xFF0A0F1E),

      // Gradient background is handled by GradientPainter
      MorphixStyle.gradient => Colors.transparent,
    };
  }

  // ── Foreground ─────────────────────────────────────────────────────

  static Color foreground({
    required MorphixState state,
    required MorphixStyle style,
    required Color base,
    required bool isDark,
    Color? successColor,
    Color? errorColor,
  }) {
    final success = successColor ?? defaultSuccess;
    final error = errorColor ?? defaultError;

    if (state == MorphixState.disabled) {
      return isDark ? const Color(0xFF555555) : const Color(0xFF9E9E9E);
    }
    if (state == MorphixState.success) return _contrastFor(success);
    if (state == MorphixState.error) return _contrastFor(error);

    return switch (style) {
      // Filled + gradient — contrast against base color
      MorphixStyle.filled || MorphixStyle.gradient => _contrastFor(base),

      // Outlined + neon — use base color as text color
      MorphixStyle.outlined || MorphixStyle.neon => base,
    };
  }

  // ── Border ─────────────────────────────────────────────────────────

  static Color border({
    required MorphixState state,
    required MorphixStyle style,
    required Color base,
    required bool isDark,
    Color? successColor,
    Color? errorColor,
  }) {
    if (style == MorphixStyle.filled) return Colors.transparent;
    if (style == MorphixStyle.gradient) return Colors.transparent;

    if (state == MorphixState.success) return successColor ?? defaultSuccess;
    if (state == MorphixState.error) return errorColor ?? defaultError;
    if (state == MorphixState.disabled) {
      return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    }

    return base;
  }

  // ── Neon glow color ────────────────────────────────────────────────

  static Color neonGlow({
    required MorphixState state,
    required Color base,
    Color? successColor,
    Color? errorColor,
  }) {
    return switch (state) {
      MorphixState.success => successColor ?? defaultSuccess,
      MorphixState.error => errorColor ?? defaultError,
      _ => base,
    };
  }

  // ── W3C contrast helper ────────────────────────────────────────────

  /// Returns black or white — whichever is more readable on [bg].
  static Color _contrastFor(Color bg) =>
      bg.computeLuminance() > 0.35 ? Colors.black : Colors.white;
}
