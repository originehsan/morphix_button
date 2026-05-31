# morphix_button

A premium animated async button for Flutter. Spring physics, particle burst, neon glow, and gradient styles — all in one widget.

![morphix_button demo](https://raw.githubusercontent.com/originehsan/morphix_button/main/assets/morphix-ezgif.com-video-to-gif-converter.gif)

[![pub.dev](https://img.shields.io/pub/v/morphix_button.svg)](https://pub.dev/packages/morphix_button)
[![pub points](https://img.shields.io/pub/points/morphix_button)](https://pub.dev/packages/morphix_button/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.10-02569B?logo=flutter)](https://flutter.dev)

## The problem

Every async button in every Flutter app has the same bug waiting to happen:

```dart
bool isLoading = false;
bool isSuccess = false;
bool isError = false;
// manage all three manually
// forget to reset one
// ship a bug
```

morphix kills this pattern entirely:

```dart
Morphix(
  label: 'Pay $49.00',
  onTap: () async => await pay(),
)
```

## Installation

```yaml
dependencies:
  morphix_button: ^1.0.0
```

## Quick start

```dart
import 'package:morphix_button/morphix_button.dart';

Morphix(
  label: 'Pay $49.00',
  onTap: () async => await pay(),
  style: MorphixStyle.filled,
  color: Color(0xFF2563EB),
  successColor: Color(0xFF16A34A),
  onSuccess: () => Navigator.pushNamed(context, '/receipt'),
  onError: (e) => showSnackBar('$e'),
)
```

## 4 Styles

**Filled** — solid color, universal CTA

```dart
Morphix(
  label: 'Continue',
  onTap: onTap,
  style: MorphixStyle.filled,
  color: Color(0xFF18181B),
  successColor: Color(0xFF16A34A),
)
```

**Outlined** — border only, secondary action

```dart
Morphix(
  label: 'Save Draft',
  onTap: onTap,
  style: MorphixStyle.outlined,
  color: Color(0xFF2563EB),
  successColor: Color(0xFF16A34A),
)
```

**Neon** — glowing border, breathing pulse on idle

```dart
Morphix(
  label: 'Start Free Trial',
  onTap: onTap,
  style: MorphixStyle.neon,
  color: Color(0xFF2563EB),
  successColor: Color(0xFF16A34A),
)
```

**Gradient** — two-color gradient that rotates during loading

```dart
Morphix(
  label: 'Upgrade to Pro',
  onTap: onTap,
  style: MorphixStyle.gradient,
  color: Color(0xFF2563EB),
  gradientColors: [
    Color(0xFF2563EB),
    Color(0xFF0D9488),
  ],
  successColor: Color(0xFF16A34A),
)
```

## 7 Animations

| Animation | Description |
|---|---|
| Liquid collapse | Width spring leads, radius follows. Center-bulge before snapping. Real `SpringSimulation` — not easing curves. |
| Rotating gradient arc | Gradient spins inside circle during loading. Gradient style only. |
| Stroke checkmark | Draws in two segments via `CustomPainter`. Not an icon. Not a fade-in. It draws. |
| Particle burst | 12 brand-color dots explode when checkmark finishes. Fade as they fly. |
| iOS shake | Three decaying oscillations on error. Auto-resets to idle. |
| Press scale | 96% on finger down, springs back on release. 80ms response. |
| Shadow bloom | Glow pulse on neon idle and during loading. |

## Progress mode

For uploads, downloads, and AI generation flows:

```dart
final ctrl = MorphixController();

void upload() {
  double p = 0.0;
  Timer.periodic(Duration(milliseconds: 80), (t) {
    p += 0.02;
    if (p >= 1.0) {
      t.cancel();
      ctrl.success();
    } else {
      ctrl.setProgress(p);
    }
  });
}

Morphix(
  label: 'Upload Video',
  onTap: null,
  controller: ctrl,
  style: MorphixStyle.gradient,
  color: Color(0xFF2563EB),
  gradientColors: [Color(0xFF2563EB), Color(0xFF0D9488)],
  successColor: Color(0xFF16A34A),
)
```

## External controller

Works with Riverpod, Bloc, GetX, MVVM:

```dart
final ctrl = MorphixController();

// Riverpod
ref.listen(paymentProvider, (_, next) {
  if (next.isLoading) ctrl.loading();
  if (next.hasValue)  ctrl.success();
  if (next.hasError)  ctrl.error();
});

Morphix(
  label: 'Pay',
  onTap: null,
  controller: ctrl,
  color: Color(0xFF2563EB),
)

// Always dispose
@override
void dispose() {
  ctrl.dispose();
  super.dispose();
}
```

## Controller API

```dart
ctrl.loading()          // → loading state
ctrl.success()          // → success state
ctrl.error()            // → error state
ctrl.reset()            // → idle state
ctrl.disable()          // → disabled state
ctrl.enable()           // → idle state
ctrl.setProgress(0.65)  // → determinate progress arc
ctrl.dispose()          // always call in dispose()
```

## Full API

```dart
Morphix(
  // Content
  label: 'Pay $49.00',
  child: Widget,
  icon: Icons.payment_rounded,
  iconPosition: IconPosition.left,

  // Async
  onTap: () async => await pay(),
  controller: ctrl,

  // Style
  style: MorphixStyle.gradient,
  color: Color(0xFF2563EB),
  gradientColors: [Color(0xFF2563EB), Color(0xFF0D9488)],
  gradientAngle: 135.0,

  // State colors
  successColor: Color(0xFF16A34A),
  errorColor: Color(0xFFDC2626),

  // Sizing
  height: 54.0,
  minWidth: 120.0,
  maxWidth: double.infinity,
  borderRadius: 32.0,
  borderWidth: 2.0,

  // Text
  textStyle: TextStyle(...),

  // Timing
  successDuration: Duration(seconds: 2),

  // Spring presets
  widthSpring: MorphixSprings.snappy,
  radiusSpring: MorphixSprings.follow,

  // Feel
  haptic: true,
  particles: true,

  // Accessibility
  focusNode: FocusNode(),
  loadingLabel: 'Loading',
  successLabel: 'Success',
  errorLabel: 'Error',

  // Speed
  animationSpeed: 1.0,

  // Callbacks
  onSuccess: () {},
  onError: (e) {},
)
```

## Spring presets

```dart
MorphixSprings.standard   // balanced — good default
MorphixSprings.snappy     // fast and tight — productivity apps
MorphixSprings.cinematic  // slow and weighted — luxury apps
MorphixSprings.bouncy     // playful overshoot — consumer apps
MorphixSprings.follow     // soft chase — ideal for radius spring
```

## Accessibility

- Keyboard navigation — Tab to focus, Enter or Space to activate

- Screen reader announcements on every state change

- Semantics labels updated per state — idle, loading, success, error, disabled

- Reduced motion — respects `MediaQuery.disableAnimations`

- Localization ready — custom labels for any language

```dart
Morphix(
  label: 'Pay $49.00',
  onTap: onTap,
  color: Color(0xFF2563EB),
  loadingLabel: 'Processing payment',
  successLabel: 'Payment successful',
  errorLabel: 'Payment failed',
)
```

## Production safety

12 vulnerabilities fixed before v1.0.0:

| # | Vulnerability | Fix |
|---|---|---|
| 1 | Rapid multi-tap | `_isBusy` guard before first `await` |
| 2 | setState after dispose | `_isDisposed` + `mounted` check |
| 3 | Synchronous throw | `Future.microtask()` wraps `onTap` |
| 4 | AnimationController after dispose | All disposed atomically |
| 5 | onTap null | Silent no-op |
| 6 | Controller after dispose | `_disposed` guard |
| 7 | successDuration zero | Clamped to 500ms |
| 8 | Controller swapped on rebuild | `didUpdateWidget` re-wires |
| 9 | Screen rotation stale width | `LayoutBuilder` every build |
| 10 | Timer after dispose | Cancelled in dispose |
| 11 | RTL languages | Directionality-agnostic |
| 12 | Long label overflow | ellipsis + padding |

## State machine

```
idle ──tap──────────────→ loading
loading ──success──────→ success ──timer──→ idle
loading ──throw────────→ error ──shake──→ idle
loading ──setProgress──→ progress ──success──→ idle
any ──controller──────→ any state
disabled ──tap─────────→ nothing
```

## Roadmap

| Version | Features |
|---|---|
| v1.0 | Core lifecycle, 4 styles, spring physics, particles, neon, gradient, progress, accessibility |
| v1.1 | MorphixTheme InheritedWidget, MorphixStyle.glass |
| v1.2 | Custom particles, custom haptics |
| v2.0 | interactix kit — MorphixLoader, MorphixCard, MorphixInput |

## License

MIT © 2025
