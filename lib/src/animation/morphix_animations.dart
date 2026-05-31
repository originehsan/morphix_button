import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../core/morphix_constants.dart';
import 'morphix_spring.dart';

/// Owns every [AnimationController] used by [MorphixButton].
/// One [dispose] call cleans everything — no leaks possible.
class MorphixAnimations {
  MorphixAnimations({
    required TickerProvider vsync,
    double speed = MorphixConstants.defaultAnimationSpeed,
    SpringDescription? widthSpring,
    SpringDescription? radiusSpring,
  }) : _widthSpring = widthSpring ?? MorphixSprings.collapse,
       _radiusSpring = radiusSpring ?? MorphixSprings.follow {
    // speed divides duration — higher speed = shorter duration
    Duration d(int ms) => Duration(milliseconds: (ms / speed).round());

    collapseWidth = AnimationController(
      vsync: vsync,
      duration: d(MorphixConstants.spinnerDurationMs),
    );
    collapseRadius = AnimationController(
      vsync: vsync,
      duration: d(MorphixConstants.spinnerDurationMs),
    );
    expand = AnimationController(
      vsync: vsync,
      duration: d(MorphixConstants.spinnerDurationMs),
    );
    spinner = AnimationController(
      vsync: vsync,
      duration: d(MorphixConstants.spinnerDurationMs),
    );
    checkmark = AnimationController(
      vsync: vsync,
      duration: d(MorphixConstants.checkmarkDurationMs),
    );
    particles = AnimationController(
      vsync: vsync,
      duration: d(MorphixConstants.particleDurationMs),
    );
    shake = AnimationController(
      vsync: vsync,
      duration: d(MorphixConstants.shakeDurationMs),
    );
    color = AnimationController(
      vsync: vsync,
      duration: d(MorphixConstants.colorDurationMs),
    );
    shadow = AnimationController(
      vsync: vsync,
      duration: d(MorphixConstants.shadowDurationMs),
    );
    press = AnimationController(
      vsync: vsync,
      duration: d(MorphixConstants.pressDurationMs),
    );
    progressArc = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
  }

  // ── Spring config ──────────────────────────────────────────────────

  final SpringDescription _widthSpring;
  final SpringDescription _radiusSpring;

  // ── Controllers ────────────────────────────────────────────────────

  /// Two controllers for liquid collapse — offset springs create the bulge.
  late final AnimationController collapseWidth;
  late final AnimationController collapseRadius;

  late final AnimationController expand;
  late final AnimationController spinner;
  late final AnimationController checkmark;
  late final AnimationController particles;
  late final AnimationController shake;
  late final AnimationController color;
  late final AnimationController shadow;
  late final AnimationController press;

  /// Drives the determinate progress arc — [MorphixState.progress].
  late final AnimationController progressArc;

  bool _disposed = false;
  bool get isDisposed => _disposed;

  // ── Spring runners ─────────────────────────────────────────────────

  /// Liquid collapse — width spring leads, radius spring follows.
  /// Uses custom springs if provided, falls back to presets.
  void runLiquidCollapse() {
    if (_disposed) return;

    collapseWidth.animateWith(SpringSimulation(_widthSpring, 0.0, 1.0, 0));

    // Radius chases width with slight delay — creates the liquid bulge
    Future.delayed(const Duration(milliseconds: 40), () {
      if (_disposed) return;
      collapseRadius.animateWith(SpringSimulation(_radiusSpring, 0.0, 1.0, 0));
    });
  }

  /// Spring expansion back to full width.
  void runExpand() {
    if (_disposed) return;
    collapseWidth.reset();
    collapseRadius.reset();
    expand.animateWith(SpringSimulation(MorphixSprings.expand, 0.0, 1.0, 0));
  }

  // ── Spinner ────────────────────────────────────────────────────────

  void startSpinner() {
    if (_disposed) return;
    spinner.stop();
    spinner.repeat();
  }

  void stopSpinner() {
    if (_disposed) return;
    spinner.stop();
  }

  // ── Progress arc ───────────────────────────────────────────────────

  /// Animates the progress arc to [value] — called on every setProgress().
  void animateProgress(double value) {
    if (_disposed) return;
    progressArc.animateTo(value, curve: Curves.easeOut);
  }

  // ── Particles ──────────────────────────────────────────────────────

  /// Fires particle burst — called by checkmark status listener.
  void burstParticles() {
    if (_disposed) return;
    particles.forward(from: 0);
  }

  // ── Shake ──────────────────────────────────────────────────────────

  /// iOS-style decaying shake — three oscillations losing energy.
  Animation<double> shakeAnimation() => TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -1.0, end: 0.7), weight: 1.5),
    TweenSequenceItem(tween: Tween(begin: 0.7, end: -0.5), weight: 1.5),
    TweenSequenceItem(tween: Tween(begin: -0.5, end: 0.3), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.0), weight: 1),
  ]).animate(CurvedAnimation(parent: shake, curve: Curves.easeOut));

  // ── Press scale ────────────────────────────────────────────────────

  void pressDown() {
    if (_disposed) return;
    press.forward();
  }

  void pressUp() {
    if (_disposed) return;
    press.reverse();
  }

  /// Scale value — 1.0 idle, 0.96 pressed.
  double get pressScale =>
      1.0 - (press.value * (1.0 - MorphixConstants.pressScale));

  // ── Dispose ────────────────────────────────────────────────────────

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    collapseWidth.dispose();
    collapseRadius.dispose();
    expand.dispose();
    spinner.dispose();
    checkmark.dispose();
    particles.dispose();
    shake.dispose();
    color.dispose();
    shadow.dispose();
    press.dispose();
    progressArc.dispose();
  }
}
