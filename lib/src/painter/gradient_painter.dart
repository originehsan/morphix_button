import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws a rotating gradient arc inside the collapsed circle.
/// Only active when [MorphixStyle.gradient] is loading.
/// [rotation] 0.0→1.0 drives one full sweep of the arc.
class GradientPainter extends CustomPainter {
  const GradientPainter({required this.rotation, required this.colors});

  final double rotation;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final strokeWidth = (size.shortestSide * 0.12).clamp(2.0, 3.0);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Faint track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = colors.first.withValues(alpha: 0.15)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    // Rotating gradient arc
    final gradient = SweepGradient(
      colors: [...colors, colors.first],
      startAngle: 0,
      endAngle: 2 * math.pi,
      transform: GradientRotation(rotation * 2 * math.pi),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      rect,
      rotation * 2 * math.pi - math.pi / 2,
      1.3,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(GradientPainter old) =>
      old.rotation != rotation || old.colors != colors;
}
