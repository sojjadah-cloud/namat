import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';

/// The splash: the mark drawing itself.
///
/// Sequenced rather than a single fade — the stroke grows, bends into the N's
/// diagonal, then the leaf opens, then the wordmark arrives. That sequence is
/// the brand's own story (a line that becomes growth) and takes about the same
/// time a cold start needs anyway.
///
/// No spinner. A spinner says "waiting"; this says "arriving", and they cost
/// the same 2.4 seconds.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  // Overlapping intervals: each element starts before the previous finishes,
  // which is what keeps it feeling like one motion instead of four.
  late final _stroke = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.05, 0.50, curve: Curves.easeInOutCubic),
  );
  late final _leaf = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.38, 0.72, curve: Curves.easeOutBack),
  );
  late final _word = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.60, 0.86, curve: Curves.easeOutCubic),
  );
  late final _motes = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.66, 1.0, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _c.forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NamatColors.canvas,
      body: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 132,
                child: CustomPaint(
                  painter: _MarkPainter(
                    stroke: _stroke.value,
                    leaf: _leaf.value.clamp(0.0, 1.0),
                    motes: _motes.value,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Opacity(
                opacity: _word.value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - _word.value)),
                  child: const Text(
                    'نمط',
                    style: TextStyle(
                      fontFamily: 'PlexArabic',
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: NamatColors.deeper,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.stroke, required this.leaf, required this.motes});

  /// 0–1 along the N's stroke.
  final double stroke;

  /// 0–1 leaf scale.
  final double leaf;

  /// 0–1 particle drift.
  final double motes;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64;
    canvas.save();
    canvas.scale(s);

    // The N as one path, revealed by measuring it rather than by clipping —
    // clipping would show a hard edge travelling across a rounded cap.
    final path = Path()
      ..moveTo(17, 55)
      ..lineTo(17, 17.5)
      ..lineTo(45, 47);

    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
    var remaining = total * stroke;

    final pen = Paint()
      ..color = NamatColors.deep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final m in metrics) {
      if (remaining <= 0) break;
      final take = math.min(remaining, m.length);
      canvas.drawPath(m.extractPath(0, take), pen);
      remaining -= take;
    }

    // The leaf opens from its own stem rather than from the canvas centre, so
    // it grows out of the mark instead of appearing beside it.
    if (leaf > 0) {
      canvas.save();
      canvas.translate(43.3, 33.8);
      canvas.scale(leaf);
      canvas.translate(-43.3, -33.8);
      canvas.drawPath(
        Path()
          ..moveTo(52, 8)
          ..cubicTo(54.3, 18.4, 51.4, 27, 43.3, 33.8)
          ..cubicTo(37.7, 24, 40.6, 15.4, 52, 8)
          ..close(),
        Paint()..color = NamatColors.sageLight,
      );
      canvas.restore();
    }

    // A few motes drifting outward, fading as they go. Leaf-coloured, not
    // white sparkles — celebration in the brand's own vocabulary.
    if (motes > 0) {
      final paint = Paint()..color = NamatColors.sage.withOpacity(0.5 * (1 - motes));
      for (var i = 0; i < 7; i++) {
        final angle = (i / 7) * 2 * math.pi;
        final drift = 14 + motes * 20;
        canvas.drawCircle(
          Offset(32 + math.cos(angle) * drift, 30 + math.sin(angle) * drift),
          1.6 * (1 - motes * 0.5),
          paint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.stroke != stroke || old.leaf != leaf || old.motes != motes;
}
