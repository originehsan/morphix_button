import 'dart:math';

/// Data model for a single particle in the burst animation.
/// Created once at burst start — [ParticlePainter] reads these
/// values every frame to compute position and opacity.
class Particle {
  Particle({required Random random}) {
    angle = random.nextDouble() * 2 * pi;
    speed = 0.4 + random.nextDouble() * 0.6;
    radius = 2.0 + random.nextDouble() * 2.0;
  }

  /// Direction the particle flies in radians.
  late final double angle;

  /// Speed multiplier — randomized so particles scatter at different rates.
  late final double speed;

  /// Dot radius in logical pixels.
  late final double radius;
}
