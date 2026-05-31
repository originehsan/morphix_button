import 'package:flutter/material.dart';
import '../animation/morphix_spring.dart';
import '../core/morphix_constants.dart';
import '../core/morphix_controller.dart';
import '../model/morphix_icon_position.dart';
import '../model/morphix_style.dart';
import 'morphix_button.dart';

/// The public-facing [Morphix] button widget.
/// Single import, single widget, full lifecycle management.
///
/// ```dart
/// Morphix(
///   label: 'Pay ₹499',
///   onTap: () async => await pay(),
///   style: MorphixStyle.neon,
///   color: Color(0xFF00D4FF),
/// )
/// ```
class Morphix extends StatelessWidget {
  const Morphix({
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

  /// Text shown in idle state. Use [child] for custom content.
  final String? label;

  /// Custom idle content — overrides [label] and [icon].
  final Widget? child;

  /// Icon shown next to [label] in idle state.
  final IconData? icon;

  /// Position of [icon] relative to [label].
  final IconPosition iconPosition;

  /// Async callback. Throw to trigger error state.
  /// Pass null when using [controller].
  final Future<void> Function()? onTap;

  /// Visual style — filled, outlined, neon, or gradient.
  final MorphixStyle style;

  /// Primary brand color.
  final Color color;

  /// Two-color gradient. Required when [style] is [MorphixStyle.gradient].
  final List<Color>? gradientColors;

  /// Gradient angle in degrees. Default is 135°.
  final double gradientAngle;

  /// Overrides the default success green.
  final Color? successColor;

  /// Overrides the default error red.
  final Color? errorColor;

  /// How long success state shows before auto-reset. Min 500ms.
  final Duration successDuration;

  /// Called after success state resets to idle.
  final VoidCallback? onSuccess;

  /// Called with the thrown error when [onTap] fails.
  final void Function(Object error)? onError;

  /// External controller for Riverpod, Bloc, GetX, MVVM.
  final MorphixController? controller;

  /// Button height in logical pixels.
  final double height;

  /// Minimum expanded width.
  final double minWidth;

  /// Maximum expanded width — prevents tablet stretching.
  final double maxWidth;

  /// Corner radius of the pill shape.
  final double borderRadius;

  /// Border thickness for outlined and neon styles.
  final double borderWidth;

  /// Override the label text style.
  final TextStyle? textStyle;

  /// Animation speed multiplier.
  /// 0.5 = cinematic slow, 1.0 = normal, 2.0 = snappy.
  final double animationSpeed;

  /// Enables haptic feedback on tap, success, and error.
  final bool haptic;

  /// Set false to disable particle burst on success.
  /// Recommended on low-end devices.
  final bool particles;

  /// Custom spring for width collapse.
  /// Use [MorphixSprings] presets or define your own [SpringDescription].
  ///
  /// ```dart
  /// widthSpring: MorphixSprings.snappy,
  /// ```
  final SpringDescription? widthSpring;

  /// Custom spring for border-radius chase.
  /// Should be softer than [widthSpring] to create the liquid bulge effect.
  final SpringDescription? radiusSpring;

  /// External focus node for custom focus management.
  /// If null, morphix creates and manages its own internally.
  final FocusNode? focusNode;

  /// Screen reader announcement for loading state.
  /// Defaults to 'Loading'. Override for localization.
  final String loadingLabel;

  /// Screen reader announcement for success state.
  /// Defaults to 'Success'. Override for localization.
  final String successLabel;

  /// Screen reader announcement for error state.
  /// Defaults to 'Error'. Override for localization.
  final String errorLabel;

  @override
  Widget build(BuildContext context) {
    return MorphixButton(
      key: key,
      label: label,
      icon: icon,
      iconPosition: iconPosition,
      onTap: onTap,
      style: style,
      color: color,
      gradientColors: gradientColors,
      gradientAngle: gradientAngle,
      successColor: successColor,
      errorColor: errorColor,
      successDuration: successDuration,
      onSuccess: onSuccess,
      onError: onError,
      controller: controller,
      height: height,
      minWidth: minWidth,
      maxWidth: maxWidth,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      textStyle: textStyle,
      animationSpeed: animationSpeed,
      haptic: haptic,
      particles: particles,
      widthSpring: widthSpring,
      radiusSpring: radiusSpring,
      focusNode: focusNode,
      loadingLabel: loadingLabel,
      successLabel: successLabel,
      errorLabel: errorLabel,
      child: child,
    );
  }
}
