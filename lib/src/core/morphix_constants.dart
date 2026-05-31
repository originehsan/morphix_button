class MorphixConstants {
  MorphixConstants._();

  // Press feel
  static const double pressScale = 0.96;
  static const int pressDurationMs = 80;

  // Liquid collapse spring
  static const double collapseStiffness = 280.0;
  static const double collapseDamping = 0.72;
  static const double liquidOvershoot = 0.15;

  // Expand spring
  static const double expandStiffness = 200.0;
  static const double expandDamping = 0.60;

  // Particles
  static const int particleCount = 12;
  static const int particleDurationMs = 600;
  static const double particleMaxRadius = 4.0;
  static const double particleMaxDistance = 36.0;

  // Spinner
  static const double spinnerSweep = 1.3;
  static const int spinnerDurationMs = 900;

  // Checkmark
  static const int checkmarkDurationMs = 500;

  // Shake
  static const int shakeDurationMs = 500;
  static const double shakeDistance = 10.0;

  // Color transition
  static const int colorDurationMs = 300;

  // Shadow bloom
  static const int shadowDurationMs = 1200;
  static const double shadowBlurBase = 8.0;
  static const double shadowBlurMax = 16.0;
  static const double shadowSpreadBase = 1.0;
  static const double shadowSpreadMax = 6.0;

  // Success timing
  static const int minSuccessMs = 500;
  static const int maxSuccessMs = 30000;

  // Defaults
  static const double defaultHeight = 54.0;
  static const double defaultBorderRadius = 32.0;
  static const double defaultBorderWidth = 2.0;
  static const double defaultMinWidth = 120.0;
  static const double defaultAnimationSpeed = 1.0;
  static const double defaultGradientAngle = 135.0;
}
