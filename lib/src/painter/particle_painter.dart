import 'dart:math';

import 'package:flutter/material.dart';

import '../core/morphix_constants.dart';
import '../model/particle.dart';

/// Draws the particle burst when the checkmark finishes drawing.
/// [progress] 0.0→1.0 moves particles outward and fades them out.
/// [particles] are generated once at burst start and reused every frame.
class ParticlePainter extends CustomPainter {
  const ParticlePainter({
    required this.progress,
    required this.color,
    required this.particles,
  });

  final double progress;
  final Color color;
  final List<Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);

    // Opacity fades as particles fly outward
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    for (final p in particles) {
      final distance =
          progress * p.speed * MorphixConstants.particleMaxDistance;

      final position = Offset(
        center.dx + cos(p.angle) * distance,
        center.dy + sin(p.angle) * distance,
      );

      canvas.drawCircle(position, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter old) =>
      old.progress != progress || old.color != color;
}
