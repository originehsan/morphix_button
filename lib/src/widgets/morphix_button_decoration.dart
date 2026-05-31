import 'package:flutter/material.dart';
import '../core/morphix_state.dart';
import '../model/morphix_style.dart';
import '../theme/morphix_theme.dart';

/// Builds [BoxDecoration] for every state and style combination.
/// Pure static method — no state, no side effects.
class MorphixDecoration {
  MorphixDecoration._();

  static BoxDecoration build({
    required MorphixState state,
    required MorphixStyle style,
    required Color base,
    required bool isDark,
    required bool isCircle,
    required double height,
    required double borderRadius,
    required double borderWidth,
    required double shadowBlur,
    required double shadowSpread,
    Color? successColor,
    Color? errorColor,
  }) {
    final bg = MorphixTheme.background(
      state: state,
      style: style,
      base: base,
      isDark: isDark,
      successColor: successColor,
      errorColor: errorColor,
    );

    final borderColor = MorphixTheme.border(
      state: state,
      style: style,
      base: base,
      isDark: isDark,
      successColor: successColor,
      errorColor: errorColor,
    );

    final glowColor = MorphixTheme.neonGlow(
      state: state,
      base: base,
      successColor: successColor,
      errorColor: errorColor,
    );

    final radius = isCircle ? height / 2 : borderRadius;

    // Outlined and neon show border — filled and gradient do not
    final showBorder =
        style == MorphixStyle.outlined ||
        style == MorphixStyle.neon ||
        state == MorphixState.success ||
        state == MorphixState.error;

    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      border: showBorder
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      boxShadow: shadowBlur > 0
          ? [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.5),
                blurRadius: shadowBlur,
                spreadRadius: shadowSpread,
              ),
            ]
          : [],
    );
  }
}
