import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/namat_colors.dart';

/// The NAMAT icon family.
///
/// Drawn with [CustomPainter] rather than shipped as a font or an SVG set, for
/// three reasons that matter here: every glyph shares one stroke width and one
/// cap style so the family reads as a family; each one can carry a leaf motif
/// that ties it to the logo; and any of them can animate a stroke, which a
/// font glyph cannot.
///
/// Stroke is 1.8 at a 24pt box and scales with the icon, so a 40pt icon does
/// not render as a hairline.
enum NamatIcons {
  home,
  use,
  challenge,
  journey,
  profile,
  meals,
  fitness,
  consultation,
  store,
  bell,
  search,
  location,
  reward,
  package,
  partner,
  leaf,
}

class NamatIcon extends StatelessWidget {
  const NamatIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.filled = false,
  });

  final NamatIcons icon;
  final double size;
  final Color? color;

  /// Selected state: the leaf accent fills instead of outlining.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _NamatIconPainter(
          icon: icon,
          color: color ?? NamatColors.ink,
          filled: filled,
        ),
      ),
    );
  }
}

class _NamatIconPainter extends CustomPainter {
  _NamatIconPainter({
    required this.icon,
    required this.color,
    required this.filled,
  });

  final NamatIcons icon;
  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    // Everything below is authored on a 24-unit grid and scaled, so the family
    // stays consistent at any size.
    final s = size.width / 24;
    canvas.save();
    canvas.scale(s);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (icon) {
      case NamatIcons.home:
        canvas.drawPath(
          Path()
            ..moveTo(4, 10.5)
            ..lineTo(12, 4)
            ..lineTo(20, 10.5)
            ..lineTo(20, 19)
            ..cubicTo(20, 19.6, 19.6, 20, 19, 20)
            ..lineTo(5, 20)
            ..cubicTo(4.4, 20, 4, 19.6, 4, 19)
            ..close(),
          stroke,
        );

      case NamatIcons.use:
        // Four fields as a quartered organic disc — the shape of a choice.
        canvas.drawCircle(const Offset(12, 12), 8, stroke);
        canvas.drawLine(const Offset(12, 4), const Offset(12, 20), stroke);
        canvas.drawLine(const Offset(4, 12), const Offset(20, 12), stroke);

      case NamatIcons.challenge:
        // Two people joined by an energy path.
        canvas.drawCircle(const Offset(6.5, 9), 3, stroke);
        canvas.drawCircle(const Offset(17.5, 9), 3, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(9.5, 13.5)
            ..cubicTo(11, 16.5, 13, 16.5, 14.5, 13.5),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(12, 17)
            ..lineTo(10.6, 20)
            ..lineTo(13.4, 20)
            ..lineTo(12, 22.6),
          stroke,
        );

      case NamatIcons.journey:
        // A winding path with a marker: progress, not a destination.
        canvas.drawPath(
          Path()
            ..moveTo(6, 20)
            ..cubicTo(6, 15, 18, 15, 18, 10)
            ..cubicTo(18, 6.5, 14.5, 5, 12, 5),
          stroke,
        );
        canvas.drawCircle(const Offset(6, 20), 1.8, filled ? fill : stroke);

      case NamatIcons.profile:
        canvas.drawCircle(const Offset(12, 8.5), 3.6, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(5, 20)
            ..cubicTo(5, 16.2, 8.1, 14.5, 12, 14.5)
            ..cubicTo(15.9, 14.5, 19, 16.2, 19, 20),
          stroke,
        );

      case NamatIcons.meals:
        // Bowl and leaf.
        canvas.drawPath(
          Path()
            ..moveTo(4, 12.5)
            ..lineTo(20, 12.5)
            ..cubicTo(20, 17, 16.4, 20, 12, 20)
            ..cubicTo(7.6, 20, 4, 17, 4, 12.5)
            ..close(),
          stroke,
        );
        _leaf(canvas, filled ? fill : stroke, const Offset(12, 4.5), 5);

      case NamatIcons.fitness:
        // A bar with movement waves rather than a literal dumbbell.
        canvas.drawLine(const Offset(7.5, 12), const Offset(16.5, 12), stroke);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(3.5, 8.5, 4, 7),
            const Radius.circular(1.6),
          ),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(16.5, 8.5, 4, 7),
            const Radius.circular(1.6),
          ),
          stroke,
        );

      case NamatIcons.consultation:
        // A person and a conversation.
        canvas.drawCircle(const Offset(9, 9), 3.2, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(3.5, 19.5)
            ..cubicTo(3.5, 15.8, 6, 14, 9, 14)
            ..cubicTo(10.4, 14, 11.7, 14.4, 12.7, 15.1),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(13, 12.5, 8, 6),
            const Radius.circular(2.4),
          ),
          stroke,
        );
        canvas.drawLine(const Offset(15.5, 18.4), const Offset(15, 21), stroke);

      case NamatIcons.store:
        // Bag with a leaf where a handle would be.
        canvas.drawPath(
          Path()
            ..moveTo(5.5, 9)
            ..lineTo(18.5, 9)
            ..lineTo(19.5, 19.2)
            ..cubicTo(19.6, 19.7, 19.2, 20.2, 18.7, 20.2)
            ..lineTo(5.3, 20.2)
            ..cubicTo(4.8, 20.2, 4.4, 19.7, 4.5, 19.2)
            ..close(),
          stroke,
        );
        _leaf(canvas, filled ? fill : stroke, const Offset(12, 3.2), 4.4);

      case NamatIcons.bell:
        canvas.drawPath(
          Path()
            ..moveTo(6, 17)
            ..lineTo(18, 17)
            ..cubicTo(16.8, 15.8, 16.6, 14.6, 16.6, 12)
            ..cubicTo(16.6, 8.8, 14.6, 6.6, 12, 6.6)
            ..cubicTo(9.4, 6.6, 7.4, 8.8, 7.4, 12)
            ..cubicTo(7.4, 14.6, 7.2, 15.8, 6, 17)
            ..close(),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(10.4, 19.4)
            ..cubicTo(11.2, 20.6, 12.8, 20.6, 13.6, 19.4),
          stroke,
        );

      case NamatIcons.search:
        canvas.drawCircle(const Offset(11, 11), 6.2, stroke);
        canvas.drawLine(const Offset(15.6, 15.6), const Offset(20, 20), stroke);

      case NamatIcons.location:
        canvas.drawPath(
          Path()
            ..moveTo(12, 21)
            ..cubicTo(16.5, 16.4, 18.5, 13.4, 18.5, 10.5)
            ..cubicTo(18.5, 6.9, 15.6, 4, 12, 4)
            ..cubicTo(8.4, 4, 5.5, 6.9, 5.5, 10.5)
            ..cubicTo(5.5, 13.4, 7.5, 16.4, 12, 21)
            ..close(),
          stroke,
        );
        canvas.drawCircle(const Offset(12, 10.4), 2.4, stroke);

      case NamatIcons.reward:
        // A leaf coin — points, in the brand's own currency.
        canvas.drawCircle(const Offset(12, 12), 8, stroke);
        _leaf(canvas, filled ? fill : stroke, const Offset(12, 7.6), 5);

      case NamatIcons.package:
        // Layered cards, the shape of a bundle.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(4, 9, 16, 11),
            const Radius.circular(2.6),
          ),
          stroke,
        );
        canvas.drawLine(const Offset(6.6, 6), const Offset(17.4, 6), stroke);
        canvas.drawLine(const Offset(8.6, 3.4), const Offset(15.4, 3.4), stroke);

      case NamatIcons.partner:
        // Two curves reaching toward each other, meeting under a leaf.
        canvas.drawPath(
          Path()
            ..moveTo(3.5, 18)
            ..cubicTo(3.5, 13.5, 8, 12.5, 11.4, 14.6),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(20.5, 18)
            ..cubicTo(20.5, 13.5, 16, 12.5, 12.6, 14.6),
          stroke,
        );
        _leaf(canvas, filled ? fill : stroke, const Offset(12, 4), 5.2);

      case NamatIcons.leaf:
        _leaf(canvas, filled ? fill : stroke, const Offset(12, 5), 8);
    }

    canvas.restore();
  }

  /// The motif that ties the family to the logo: a leaf leaning right, the
  /// same lean as the mark's own.
  void _leaf(Canvas canvas, Paint paint, Offset top, double length) {
    final w = length * 0.52;
    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..cubicTo(
        top.dx + w, top.dy + length * 0.28,
        top.dx + w * 0.72, top.dy + length * 0.86,
        top.dx, top.dy + length,
      )
      ..cubicTo(
        top.dx - w * 0.72, top.dy + length * 0.86,
        top.dx - w, top.dy + length * 0.28,
        top.dx, top.dy,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NamatIconPainter old) =>
      old.icon != icon || old.color != color || old.filled != filled;
}

/// The logo mark: the N's leg and diagonal as one stroke, with the leaf
/// standing where the right leg would be.
class NamatLogoMark extends StatelessWidget {
  const NamatLogoMark({super.key, this.size = 40, this.mono});

  final double size;

  /// When set, both shapes paint in this colour — for use on green surfaces.
  final Color? mono;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _LogoPainter(mono: mono)),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({this.mono});
  final Color? mono;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64;
    canvas.save();
    canvas.scale(s);

    canvas.drawPath(
      Path()
        ..moveTo(17, 55)
        ..lineTo(17, 17.5)
        ..lineTo(45, 47),
      Paint()
        ..color = mono ?? NamatColors.deep
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      Path()
        ..moveTo(52, 8)
        ..cubicTo(54.3, 18.4, 51.4, 27, 43.3, 33.8)
        ..cubicTo(37.7, 24, 40.6, 15.4, 52, 8)
        ..close(),
      Paint()
        ..color = mono?.withOpacity(0.7) ?? NamatColors.sageLight
        ..style = PaintingStyle.fill,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.mono != mono;
}

/// Progress as a ring, filling from zero when it first appears.
///
/// Under RTL the sweep mirrors, so progress grows anticlockwise — which is the
/// direction an Arabic reader expects it to.
class NamatProgressRing extends StatelessWidget {
  const NamatProgressRing({
    super.key,
    required this.value,
    this.size = 96,
    this.stroke = 8,
    this.color = NamatColors.deep,
    this.track = NamatColors.greenSoft,
    this.child,
  });

  /// 0–1.
  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Color track;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: NamatMotion.reveal,
      curve: NamatMotion.curve,
      builder: (context, v, _) => SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(
                value: v,
                stroke: stroke,
                color: color,
                track: track,
                rtl: rtl,
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.stroke,
    required this.color,
    required this.track,
    required this.rtl,
  });

  final double value;
  final double stroke;
  final Color color;
  final Color track;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final centre = rect.center;
    final radius = (size.width - stroke) / 2;

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (value <= 0) return;

    // Both directions start at twelve o'clock; only the sweep reverses.
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * value * (rtl ? -1 : 1);

    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      start,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.rtl != rtl;
}
