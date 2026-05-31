import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morphix_button/morphix_button.dart';

void main() => runApp(const MorphixExampleApp());

class MorphixExampleApp extends StatelessWidget {
  const MorphixExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morphix Button',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFFFAFAF9),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF18181B),
          surface: Color(0xFFFAFAF9),
        ),
      ),
      home: const ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  // Controller for manual progress driving (upload/download flows).
  // Always dispose in State.dispose().
  final _progressController = MorphixController();
  Timer? _progressTimer;

  @override
  void dispose() {
    _progressController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  // Returns normally → morphix transitions to success automatically.
  Future<void> _success() async =>
      Future.delayed(const Duration(seconds: 2));

  // Throws → morphix catches it, transitions to error + shake.
  // You never catch this yourself. Just throw.
  Future<void> _error() async {
    await Future.delayed(const Duration(seconds: 2));
    throw Exception('Something went wrong');
  }

  // Drives progress 0.0 → 1.0 via controller.
  // In production: replace with your upload stream or dio onSendProgress.
  Future<void> _driveProgress() async {
    double p = 0.0;
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      p += 0.02;
      if (p >= 1.0) {
        t.cancel();
        _progressController.success();
      } else {
        _progressController.setProgress(p);
      }
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF18181B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 36),
              _header(),
              const SizedBox(height: 52),

              // Filled — primary CTA.
              // Throw inside onTap to trigger error state automatically.
              _section('FILLED'),
              const SizedBox(height: 12),
              Morphix(
                label: 'Pay \$49.00',
                onTap: _success,
                style: MorphixStyle.filled,
                color: const Color(0xFF2563EB),
                successColor: const Color(0xFF0D9488),
              ),
              const SizedBox(height: 10),
              Morphix(
                label: 'Delete Account',
                onTap: _error,
                style: MorphixStyle.filled,
                color: const Color(0xFFDC2626),
                successColor: const Color(0xFF16A34A),
                errorColor: const Color(0xFFD97706),
                onError: (e) => _toast('$e'),
              ),
              const SizedBox(height: 44),

              // Outlined — secondary action.
              _section('OUTLINED'),
              const SizedBox(height: 12),
              Morphix(
                label: 'Save Draft',
                onTap: _success,
                style: MorphixStyle.outlined,
                color: const Color(0xFF2563EB),
                successColor: const Color(0xFF16A34A),
              ),
              const SizedBox(height: 44),

              // Neon — hero CTA. Glow breathes on idle automatically.
              _section('NEON'),
              const SizedBox(height: 12),
              Morphix(
                label: 'Start Free Trial',
                onTap: _success,
                style: MorphixStyle.neon,
                color: const Color(0xFF2563EB),
                successColor: const Color(0xFF16A34A),
              ),
              const SizedBox(height: 10),
              Morphix(
                label: 'End Session',
                onTap: _error,
                style: MorphixStyle.neon,
                color: const Color(0xFFDC2626),
                errorColor: const Color(0xFFD97706),
                onError: (e) => _toast('$e'),
              ),
              const SizedBox(height: 44),

              // Gradient — premium tier. Arc rotates during loading.
              // Keep both colors in the same temperature family.
              _section('GRADIENT'),
              const SizedBox(height: 12),
              Morphix(
                label: 'Upgrade to Pro',
                onTap: _success,
                style: MorphixStyle.gradient,
                color: const Color(0xFF2563EB),
                gradientColors: const [
                  Color(0xFF2563EB),
                  Color(0xFF0D9488),
                ],
                successColor: const Color(0xFF15803D),
              ),
              const SizedBox(height: 44),

              // Icon — pass any IconData, hides during loading automatically.
              _section('WITH ICON'),
              const SizedBox(height: 12),
              Morphix(
                label: 'Send Message',
                icon: Icons.send_rounded,
                iconPosition: IconPosition.right,
                onTap: _success,
                style: MorphixStyle.filled,
                color: const Color(0xFF18181B),
                successColor: const Color(0xFF16A34A),
              ),
              const SizedBox(height: 44),

              // Custom child — overrides label and icon entirely.
              // All animations still apply.
              _section('CUSTOM CHILD'),
              const SizedBox(height: 12),
              Morphix(
                onTap: _success,
                style: MorphixStyle.filled,
                color: const Color(0xFF18181B),
                successColor: const Color(0xFF16A34A),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.apple, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Sign in with Apple',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 44),

              // Progress mode — drive from your upload stream via controller.
              // ctrl.setProgress(0.0–1.0) → ctrl.success() or ctrl.error()
              _section('PROGRESS MODE'),
              const SizedBox(height: 12),
              Morphix(
                label: 'Upload Video',
                onTap: _driveProgress,
                controller: _progressController,
                style: MorphixStyle.gradient,
                color: const Color(0xFF2563EB),
                gradientColors: const [
                  Color(0xFF2563EB),
                  Color(0xFF0D9488),
                ],
                successColor: const Color(0xFF16A34A),
              ),
              const SizedBox(height: 44),

              // Spring presets — override collapse physics.
              // widthSpring drives collapse, radiusSpring chases it.
              _section('SPRING PRESETS'),
              const SizedBox(height: 12),
              Morphix(
                label: 'Snappy',
                onTap: _success,
                style: MorphixStyle.filled,
                color: const Color(0xFF18181B),
                successColor: const Color(0xFF16A34A),
                widthSpring: MorphixSprings.snappy,
                radiusSpring: MorphixSprings.snappy,
              ),
              const SizedBox(height: 10),
              Morphix(
                label: 'Bouncy',
                onTap: _success,
                style: MorphixStyle.neon,
                color: const Color(0xFF2563EB),
                successColor: const Color(0xFF16A34A),
                widthSpring: MorphixSprings.bouncy,
                radiusSpring: MorphixSprings.follow,
              ),
              const SizedBox(height: 10),
              Morphix(
                label: 'Cinematic',
                onTap: _success,
                style: MorphixStyle.gradient,
                color: const Color(0xFF16A34A),
                gradientColors: const [
                  Color(0xFF16A34A),
                  Color(0xFF0D9488),
                ],
                successColor: const Color(0xFF15803D),
                widthSpring: MorphixSprings.cinematic,
                radiusSpring: MorphixSprings.cinematic,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'morphix_button',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFF18181B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Animated async button for Flutter',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF71717A),
          ),
        ),
      ],
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFFA1A1AA),
            letterSpacing: 1.4,
          ),
        ),
      );
}