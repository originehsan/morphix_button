import 'package:flutter/material.dart';

/// Draws a checkmark stroke-by-stroke driven by [progress].
/// Two segments — short downstroke then long upstroke.
/// Progress 0.0→0.5 draws segment one, 0.5→1.0 draws segment two.
class CheckmarkPainter extends CustomPainter {
  const CheckmarkPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 2.5,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Nothing to draw yet
    if (progress <= 0) return;

    // Clamp against spring physics overshoot
    final t = progress.clamp(0.0, 1.0);

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // All points are percentage-based — works at any button size
    final p1 = Offset(size.width * 0.18, size.height * 0.52);
    final p2 = Offset(size.width * 0.42, size.height * 0.72);
    final p3 = Offset(size.width * 0.82, size.height * 0.28);

    final path = Path();

    if (t <= 0.5) {
      // Segment 1 — p1 to p2
      final seg = t / 0.5;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(_lerp(p1.dx, p2.dx, seg), _lerp(p1.dy, p2.dy, seg));
    } else {
      // Segment 1 fully drawn
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);

      // Segment 2 — p2 to p3
      final seg = (t - 0.5) / 0.5;
      path.lineTo(_lerp(p2.dx, p3.dx, seg), _lerp(p2.dy, p3.dy, seg));
    }

    canvas.drawPath(path, paint);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(CheckmarkPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
