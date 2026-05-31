import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws an indeterminate loading spinner arc.
/// [rotation] drives full rotation — 0.0 to 1.0 is one complete turn.
class SpinnerPainter extends CustomPainter {
  const SpinnerPainter({required this.rotation, required this.color});

  final double rotation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Guard against zero size canvas
    if (size.isEmpty) return;

    // Stroke width derived from canvas size — safe at any button height
    final strokeWidth = (size.shortestSide * 0.12).clamp(2.0, 3.0);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Faint track — same color, low opacity
    canvas.drawCircle(
      center,
      radius,
      paint..color = color.withValues(alpha: 0.15),
    );

    // Active arc — fixed sweep of ~75 degrees
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      rotation * 2 * math.pi - math.pi / 2,
      1.3,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(SpinnerPainter old) =>
      old.rotation != rotation || old.color != color;
}
