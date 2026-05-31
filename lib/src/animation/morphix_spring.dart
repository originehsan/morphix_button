import 'package:flutter/physics.dart';

import '../core/morphix_constants.dart';

/// Spring presets for morphix animations.
/// Tuning spring feel never touches animation controller logic.
class MorphixSprings {
  MorphixSprings._();

  // ── Internal presets ───────────────────────────────────────────────

  /// Elastic collapse into circle — stiff, slight overshoot.
  static SpringDescription get collapse => SpringDescription.withDampingRatio(
    mass: 1.0,
    stiffness: MorphixConstants.collapseStiffness,
    ratio: MorphixConstants.collapseDamping,
  );

  /// Spring expansion back to full width — softer, more elastic.
  static SpringDescription get expand => SpringDescription.withDampingRatio(
    mass: 1.0,
    stiffness: MorphixConstants.expandStiffness,
    ratio: MorphixConstants.expandDamping,
  );

  // ── Public presets — pass via widthSpring / radiusSpring ──────────

  /// Balanced feel — good default for most use cases.
  static const SpringDescription standard = SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 15.0,
  );

  /// Fast and tight — ideal for productivity or dashboard UIs.
  static const SpringDescription snappy = SpringDescription(
    mass: 0.5,
    stiffness: 400.0,
    damping: 20.0,
  );

  /// Slow and weighted — luxury or cinematic apps.
  static const SpringDescription cinematic = SpringDescription(
    mass: 1.5,
    stiffness: 100.0,
    damping: 12.0,
  );

  /// Bouncy overshoot — playful, consumer apps.
  static const SpringDescription bouncy = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 8.0,
  );

  /// Follows the width spring with a slight delay — used for radius.
  static const SpringDescription follow = SpringDescription(
    mass: 0.8,
    stiffness: 150.0,
    damping: 10.0,
  );
}
