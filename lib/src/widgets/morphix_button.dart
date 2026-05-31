import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import '../animation/morphix_animations.dart';
import '../core/morphix_constants.dart';
import '../core/morphix_controller.dart';
import '../core/morphix_state.dart';
import '../model/morphix_icon_position.dart';
import '../model/morphix_style.dart';
import '../model/particle.dart';
import '../animation/morphix_spring.dart';
import 'morphix_button_content.dart';
import 'morphix_button_decoration.dart';
import 'morphix_button_tap.dart';

/// Core button widget — owns state machine, animation triggers,
/// and lifecycle. Does not build decoration or content directly.
class MorphixButton extends StatefulWidget {
  const MorphixButton({
    super.key,
    this.label,
    this.child,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.onTap,
    this.style = MorphixStyle.filled,
    required this.color,
    this.gradientColors,
    this.gradientAngle = MorphixConstants.defaultGradientAngle,
    this.successColor,
    this.errorColor,
    this.successDuration = const Duration(seconds: 2),
    this.onSuccess,
    this.onError,
    this.controller,
    this.height = MorphixConstants.defaultHeight,
    this.minWidth = MorphixConstants.defaultMinWidth,
    this.maxWidth = double.infinity,
    this.borderRadius = MorphixConstants.defaultBorderRadius,
    this.borderWidth = MorphixConstants.defaultBorderWidth,
    this.textStyle,
    this.animationSpeed = MorphixConstants.defaultAnimationSpeed,
    this.haptic = true,
    this.particles = true,
    this.widthSpring,
    this.radiusSpring,
    this.focusNode,
    this.loadingLabel = 'Loading',
    this.successLabel = 'Success',
    this.errorLabel = 'Error',
  });

  final String? label;
  final Widget? child;
  final IconData? icon;
  final IconPosition iconPosition;
  final Future<void> Function()? onTap;
  final MorphixStyle style;
  final Color color;
  final List<Color>? gradientColors;
  final double gradientAngle;
  final Color? successColor;
  final Color? errorColor;
  final Duration successDuration;
  final VoidCallback? onSuccess;
  final void Function(Object error)? onError;
  final MorphixController? controller;
  final double height;
  final double minWidth;
  final double maxWidth;
  final double borderRadius;
  final double borderWidth;
  final TextStyle? textStyle;
  final double animationSpeed;
  final bool haptic;

  /// Set false to disable particle burst — recommended on low-end devices.
  final bool particles;

  /// Custom spring for width collapse. Defaults to [MorphixSprings.collapse].
  final SpringDescription? widthSpring;

  /// Custom spring for border-radius chase. Defaults to [MorphixSprings.follow].
  final SpringDescription? radiusSpring;

  /// External focus node — pass your own for custom focus management.
  final FocusNode? focusNode;

  /// Screen reader label for loading state.
  final String loadingLabel;

  /// Screen reader label for success state.
  final String successLabel;

  /// Screen reader label for error state.
  final String errorLabel;

  @override
  State<MorphixButton> createState() => _MorphixButtonState();
}

class _MorphixButtonState extends State<MorphixButton>
    with TickerProviderStateMixin {
  late MorphixAnimations _anim;
  late FocusNode _focusNode;

  MorphixState _state = MorphixState.idle;
  bool _isBusy = false;
  bool _isDisposed = false;
  double _fullWidth = MorphixConstants.defaultMinWidth;
  Timer? _successTimer;

  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _anim = MorphixAnimations(
      vsync: this,
      speed: widget.animationSpeed,
      widthSpring: widget.widthSpring,
      radiusSpring: widget.radiusSpring,
    );

    // Use external FocusNode if provided, else create internal one
    _focusNode = widget.focusNode ?? FocusNode();

    final rng = Random();
    _particles = List.generate(
      MorphixConstants.particleCount,
      (_) => Particle(random: rng),
    );

    widget.controller?.addListener(_onControllerChange);

    if (widget.controller != null) {
      _state = widget.controller!.state;
    }

    if (widget.style == MorphixStyle.neon) {
      _anim.shadow.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MorphixButton old) {
    super.didUpdateWidget(old);

    if (old.controller != widget.controller) {
      old.controller?.removeListener(_onControllerChange);
      widget.controller?.addListener(_onControllerChange);
    }

    // Swap focus node if external one changed
    if (old.focusNode != widget.focusNode) {
      if (old.focusNode == null) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
    }
  }

  void _onControllerChange() {
    if (_isDisposed || !mounted) return;

    // Handle progress state separately — animate arc value
    if (widget.controller!.state == MorphixState.progress) {
      if (_state != MorphixState.progress) {
        _transitionTo(MorphixState.progress);
      } else {
        _anim.animateProgress(widget.controller!.progress);
        setState(() {});
      }
      return;
    }

    _transitionTo(widget.controller!.state);
  }

  // ── Tap ────────────────────────────────────────────────────────────

  Future<void> _handleTap() async {
    if (_isBusy || _state != MorphixState.idle) return;
    if (widget.onTap == null) return;

    _isBusy = true;
    _transitionTo(MorphixState.loading);

    try {
      await Future.microtask(widget.onTap!);
      if (!_isDisposed && mounted) _transitionTo(MorphixState.success);
    } catch (e) {
      if (!_isDisposed && mounted) {
        widget.onError?.call(e);
        _transitionTo(MorphixState.error);
      }
    } finally {
      _isBusy = false;
    }
  }

  // ── State machine ──────────────────────────────────────────────────

  void _transitionTo(MorphixState next) {
    if (_isDisposed || !mounted) return;
    if (_state == next) return;
    setState(() => _state = next);
    _announceState(next);
    _runAnimations(next);
  }

  /// Announces state change to screen readers.
  void _announceState(MorphixState state) {
    final message = switch (state) {
      MorphixState.loading => widget.loadingLabel,
      MorphixState.success => widget.successLabel,
      MorphixState.error => widget.errorLabel,
      MorphixState.progress => widget.loadingLabel,
      _ => null,
    };
    if (message != null) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }

  void _runAnimations(MorphixState next) {
    // Reduced motion — skip all animations if user requested it
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    switch (next) {
      case MorphixState.loading:
        if (!reduceMotion) _anim.runLiquidCollapse();
        _anim.startSpinner();
        _anim.shadow.repeat(reverse: true);
        _anim.color.forward(from: 0);

      case MorphixState.progress:
        // Collapse to circle like loading, show progress arc
        if (!reduceMotion) _anim.runLiquidCollapse();
        _anim.stopSpinner();
        _anim.animateProgress(widget.controller?.progress ?? 0.0);
        _anim.color.forward(from: 0);

      case MorphixState.success:
        _anim.stopSpinner();
        _anim.shadow.stop();
        _anim.color.forward(from: 0);
        _anim.checkmark.removeStatusListener(_onCheckmarkDone);
        _anim.checkmark.addStatusListener(_onCheckmarkDone);
        _anim.checkmark.forward(from: 0);
        if (widget.haptic) MorphixTapHandler.successHaptic();
        _scheduleReset();

      case MorphixState.error:
        _anim.stopSpinner();
        _anim.shadow.stop();
        _anim.color.forward(from: 0);
        if (!reduceMotion) {
          _anim.shake.removeStatusListener(_onShakeDone);
          _anim.shake.addStatusListener(_onShakeDone);
          _anim.shake.forward(from: 0);
        } else {
          // Skip shake animation — go straight to idle
          _onShakeDone(AnimationStatus.completed);
        }
        if (widget.haptic) MorphixTapHandler.errorHaptic();

      case MorphixState.idle:
        if (!reduceMotion) _anim.runExpand();
        _anim.checkmark.reset();
        _anim.progressArc.reset();
        _anim.color.forward(from: 0);
        if (widget.style == MorphixStyle.neon) {
          _anim.shadow.repeat(reverse: true);
        }

      case MorphixState.disabled:
        _anim.stopSpinner();
        _anim.shadow.stop();
        _anim.color.forward(from: 0);
    }
  }

  void _onCheckmarkDone(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _anim.checkmark.removeStatusListener(_onCheckmarkDone);
      if (!_isDisposed && mounted && widget.particles) {
        _anim.burstParticles();
      }
    }
  }

  void _onShakeDone(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _anim.shake.removeStatusListener(_onShakeDone);
      if (!_isDisposed && mounted) _transitionTo(MorphixState.idle);
    }
  }

  void _scheduleReset() {
    final duration = Duration(
      milliseconds: widget.successDuration.inMilliseconds.clamp(
        MorphixConstants.minSuccessMs,
        MorphixConstants.maxSuccessMs,
      ),
    );
    _successTimer?.cancel();
    _successTimer = Timer(duration, () {
      if (_isDisposed || !mounted) return;
      widget.onSuccess?.call();
      _transitionTo(MorphixState.idle);
    });
  }

  // ── Width computation ──────────────────────────────────────────────

  double _computeWidth() {
    final full = _fullWidth.clamp(widget.minWidth, widget.maxWidth);
    final circle = widget.height;

    if (_state == MorphixState.loading ||
        _state == MorphixState.progress ||
        _state == MorphixState.success ||
        _state == MorphixState.error) {
      final t = _anim.collapseWidth.value.clamp(0.0, 1.0);
      return _lerp(full, circle, t);
    }

    if (_anim.expand.value > 0) {
      final t = _anim.expand.value.clamp(0.0, 1.0);
      return _lerp(circle, full, t);
    }

    return full;
  }

  double _computeBorderRadius() {
    final full = widget.borderRadius;
    final circle = widget.height / 2;

    if (_state == MorphixState.loading ||
        _state == MorphixState.progress ||
        _state == MorphixState.success ||
        _state == MorphixState.error) {
      final t = _anim.collapseRadius.value.clamp(0.0, 1.0);
      return _lerp(full, circle, t);
    }

    if (_anim.expand.value > 0) {
      final t = _anim.expand.value.clamp(0.0, 1.0);
      return _lerp(circle, full, t);
    }

    return full;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  List<Color> _resolvedGradientColors() {
    final colors = widget.gradientColors;
    if (colors != null && colors.length >= 2) return colors;
    return [widget.color, widget.color.withValues(alpha: 0.6)];
  }

  double _shadowBlur() {
    final isNeonIdle =
        widget.style == MorphixStyle.neon && _state == MorphixState.idle;
    if (_state == MorphixState.loading || isNeonIdle) {
      return MorphixConstants.shadowBlurBase +
          _anim.shadow.value * MorphixConstants.shadowBlurMax;
    }
    return 0.0;
  }

  double _shadowSpread() {
    final isNeonIdle =
        widget.style == MorphixStyle.neon && _state == MorphixState.idle;
    if (_state == MorphixState.loading || isNeonIdle) {
      return MorphixConstants.shadowSpreadBase +
          _anim.shadow.value * MorphixConstants.shadowSpreadMax;
    }
    return 0.0;
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isCircle =
        _state == MorphixState.loading ||
        _state == MorphixState.progress ||
        _state == MorphixState.success ||
        _state == MorphixState.error;

    return Semantics(
      button: true,
      enabled:
          _state != MorphixState.disabled &&
          _state != MorphixState.loading &&
          _state != MorphixState.progress,
      label: _semanticsLabel(),
      child: FocusableActionDetector(
        focusNode: _focusNode,
        enabled: _state != MorphixState.disabled,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => _handleTap(),
          ),
        },
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth != double.infinity) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_isDisposed &&
                    mounted &&
                    constraints.maxWidth != _fullWidth) {
                  setState(() => _fullWidth = constraints.maxWidth);
                }
              });
            }

            return AnimatedBuilder(
              animation: Listenable.merge([
                _anim.collapseWidth,
                _anim.collapseRadius,
                _anim.expand,
                _anim.spinner,
                _anim.checkmark,
                _anim.particles,
                _anim.progressArc,
                _anim.shake,
                _anim.shadow,
                _anim.color,
                _anim.press,
              ]),
              builder: (context, _) {
                final width = _computeWidth();
                final radius = _computeBorderRadius();
                final shakeOffset =
                    _anim.shakeAnimation().value *
                    MorphixConstants.shakeDistance;

                return Transform.scale(
                  scale: _anim.pressScale,
                  child: Transform.translate(
                    offset: Offset(
                      _state == MorphixState.error ? shakeOffset : 0,
                      0,
                    ),
                    child: GestureDetector(
                      onTapDown: (_) => MorphixTapHandler.onTapDown(
                        state: _state,
                        haptic: widget.haptic,
                        onPressDown: _anim.pressDown,
                      ),
                      onTapUp: (_) =>
                          MorphixTapHandler.onTapUp(onPressUp: _anim.pressUp),
                      onTapCancel: () => MorphixTapHandler.onTapCancel(
                        onPressUp: _anim.pressUp,
                      ),
                      onTap: _state == MorphixState.idle && widget.onTap != null
                          ? _handleTap
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        width: width,
                        height: widget.height,
                        decoration: MorphixDecoration.build(
                          state: _state,
                          style: widget.style,
                          base: widget.color,
                          isDark: isDark,
                          isCircle: isCircle,
                          height: widget.height,
                          borderRadius: radius,
                          borderWidth: widget.borderWidth,
                          shadowBlur: _shadowBlur(),
                          shadowSpread: _shadowSpread(),
                          successColor: widget.successColor,
                          errorColor: widget.errorColor,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
                          child: MorphixContent(
                            state: _state,
                            style: widget.style,
                            base: widget.color,
                            isDark: isDark,
                            isCircle: isCircle,
                            height: widget.height,
                            spinnerRotation: _anim.spinner.value,
                            checkmarkProgress: _anim.checkmark.value,
                            particleProgress: _anim.particles.value,
                            progressArcValue: _anim.progressArc.value,
                            particles: _particles,
                            gradientColors: _resolvedGradientColors(),
                            showParticles: widget.particles,
                            label: widget.label,
                            icon: widget.icon,
                            iconPosition: widget.iconPosition,
                            textStyle: widget.textStyle,
                            successColor: widget.successColor,
                            errorColor: widget.errorColor,
                            child: widget.child,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _semanticsLabel() => switch (_state) {
    MorphixState.idle => widget.label ?? '',
    MorphixState.loading => widget.loadingLabel,
    MorphixState.progress => widget.loadingLabel,
    MorphixState.success => widget.successLabel,
    MorphixState.error => widget.errorLabel,
    MorphixState.disabled => '${widget.label ?? ''}, disabled',
  };

  @override
  void dispose() {
    _isDisposed = true;
    _successTimer?.cancel();
    widget.controller?.removeListener(_onControllerChange);
    // Only dispose focus node if we created it internally
    if (widget.focusNode == null) _focusNode.dispose();
    _anim.dispose();
    super.dispose();
  }
}
