import 'package:flutter/material.dart';

import '../core/morphix_state.dart';
import '../model/morphix_icon_position.dart';
import '../model/morphix_style.dart';
import '../model/particle.dart';
import '../painter/checkmark_painter.dart';
import '../painter/gradient_painter.dart';
import '../painter/particle_painter.dart';
import '../painter/progress_arc_painter.dart';
import '../painter/spinner_painter.dart';
import '../theme/morphix_theme.dart';

/// Renders the content inside the button.
/// Stateless — owns no state, receives everything as params.
class MorphixContent extends StatelessWidget {
  const MorphixContent({
    super.key,
    required this.state,
    required this.style,
    required this.base,
    required this.isDark,
    required this.isCircle,
    required this.height,
    required this.spinnerRotation,
    required this.checkmarkProgress,
    required this.particleProgress,
    required this.progressArcValue,
    required this.particles,
    required this.gradientColors,
    required this.showParticles,
    this.label,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.textStyle,
    Color? successColor,
    Color? errorColor,
    this.child,
  }) : _successColor = successColor,
       _errorColor = errorColor;

  final MorphixState state;
  final MorphixStyle style;
  final Color base;
  final bool isDark;
  final bool isCircle;
  final double height;
  final double spinnerRotation;
  final double checkmarkProgress;
  final double particleProgress;

  /// Current determinate progress value — used in [MorphixState.progress].
  final double progressArcValue;

  final List<Particle> particles;
  final List<Color> gradientColors;

  /// When false particles are skipped — use on low-end devices.
  final bool showParticles;

  final String? label;
  final IconData? icon;
  final IconPosition iconPosition;
  final TextStyle? textStyle;
  final Color? _successColor;
  final Color? _errorColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final fg = MorphixTheme.foreground(
      state: state,
      style: style,
      base: base,
      isDark: isDark,
      successColor: _successColor,
      errorColor: _errorColor,
    );

    if (!isCircle) return _idleContent(fg);
    return _circleContent(fg);
  }

  // ── Idle content ───────────────────────────────────────────────────

  Widget _idleContent(Color fg) {
    final content = _buildIdleChild(fg);

    // Gradient style — paint linear gradient fill behind content
    if (style == MorphixStyle.gradient) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _GradientFillPainter(colors: gradientColors)),
          content,
        ],
      );
    }

    return content;
  }

  Widget _buildIdleChild(Color fg) {
    if (child != null) return Center(child: child);

    if (icon != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: iconPosition == IconPosition.left
                ? [_icon(fg), const SizedBox(width: 8), _label(fg)]
                : [_label(fg), const SizedBox(width: 8), _icon(fg)],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _label(fg),
      ),
    );
  }

  // ── Circle content ─────────────────────────────────────────────────

  Widget _circleContent(Color fg) {
    final iconSize = height * 0.42;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Indeterminate spinner
        if (state == MorphixState.loading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: style == MorphixStyle.gradient
                ? CustomPaint(
                    painter: GradientPainter(
                      rotation: spinnerRotation,
                      colors: gradientColors,
                    ),
                  )
                : CustomPaint(
                    painter: SpinnerPainter(
                      rotation: spinnerRotation,
                      color: fg,
                    ),
                  ),
          ),

        // Determinate progress arc
        if (state == MorphixState.progress)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CustomPaint(
              painter: ProgressArcPainter(
                progress: progressArcValue,
                color: fg,
              ),
            ),
          ),

        // Checkmark
        if (state == MorphixState.success)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CustomPaint(
              painter: CheckmarkPainter(progress: checkmarkProgress, color: fg),
            ),
          ),

        // Error X
        if (state == MorphixState.error)
          Icon(Icons.close_rounded, color: fg, size: iconSize),

        // Particles — skipped when showParticles is false
        if (showParticles && particleProgress > 0)
          SizedBox(
            width: height * 2,
            height: height * 2,
            child: CustomPaint(
              painter: ParticlePainter(
                progress: particleProgress,
                color: base,
                particles: particles,
              ),
            ),
          ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Widget _label(Color fg) => Text(
    label ?? '',
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style:
        (textStyle ??
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ))
            .copyWith(color: fg),
  );

  Widget _icon(Color fg) => Icon(icon, color: fg, size: 20);
}

// ── Gradient fill painter ──────────────────────────────────────────────

/// Paints a static linear gradient fill for gradient style in idle state.
class _GradientFillPainter extends CustomPainter {
  const _GradientFillPainter({required this.colors});

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_GradientFillPainter old) => old.colors != colors;
}
