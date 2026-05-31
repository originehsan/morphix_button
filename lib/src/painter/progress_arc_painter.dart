import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws a determinate progress arc driven by [progress] 0.0→1.0.
/// Visually consistent with [SpinnerPainter] — same stroke style.
/// Used when [MorphixState.progress] is active.
class ProgressArcPainter extends CustomPainter {
  const ProgressArcPainter({required this.progress, required this.color});

  /// Completion percentage — 0.0 is empty, 1.0 is full circle.
  final double progress;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final strokeWidth = (size.shortestSide * 0.12).clamp(2.0, 3.0);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Faint track — same as spinner for visual consistency
    canvas.drawCircle(
      center,
      radius,
      paint..color = color.withValues(alpha: 0.15),
    );

    // Progress arc — fills clockwise from top
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(ProgressArcPainter old) =>
      old.progress != progress || old.color != color;
}
