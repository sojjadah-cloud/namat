import 'package:flutter/material.dart';

import '../theme/namat_colors.dart';

/// The Omani coastline, drawn in one hairline.
///
/// From the brand board: a fort with its flag, the port cranes beside it, a
/// dhow on the water, palms, and a minaret — the working seafront of Sohar,
/// which is where NAMAT launches. Line art rather than a photograph, for the
/// same reason nothing else in this app uses one: a photograph of a real place
/// is a specific claim, and a drawn horizon is a mood.
///
/// Painted rather than shipped as an asset so it takes the theme's colours,
/// scales to any width without a second file, and costs nothing to load on a
/// slow connection — which for a first screen is the whole game.
class NamatSkyline extends StatelessWidget {
  const NamatSkyline({
    super.key,
    this.color = NamatColors.sage,
    this.opacity = 0.55,
  });

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SkylinePainter(color: color, opacity: opacity),
        size: Size.infinite,
      ),
    );
  }
}

class _SkylinePainter extends CustomPainter {
  _SkylinePainter({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Everything is laid out against a 1000-unit width and anchored to the
    // bottom, so the drawing keeps its proportions on a phone and on a tablet
    // rather than stretching.
    final scale = w / 1000;
    final baseline = h;

    double x(double v) => v * scale;
    double y(double up) => baseline - up * scale;

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withOpacity(opacity);

    final faint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(opacity * 0.45);

    // ------------------------------------------------------------- the sea
    // Four nested arcs sweeping in from the leading edge, echoing the swirl on
    // the brand board.
    for (var i = 0; i < 4; i++) {
      final lift = 92 + i * 26.0;
      canvas.drawPath(
        Path()
          ..moveTo(x(-40), y(lift * 0.35))
          ..cubicTo(
            x(60),
            y(lift),
            x(150),
            y(lift * 0.95),
            x(260),
            y(30),
          ),
        faint,
      );
    }

    // The waterline itself, running the full width.
    canvas.drawPath(
      Path()
        ..moveTo(0, y(26))
        ..cubicTo(x(200), y(18), x(420), y(40), x(1000), y(20)),
      line,
    );

    // A dhow, small and far out. One sail and a hull.
    canvas
      ..drawPath(
        Path()
          ..moveTo(x(238), y(30))
          ..lineTo(x(262), y(30))
          ..lineTo(x(256), y(22))
          ..lineTo(x(244), y(22))
          ..close(),
        line,
      )
      ..drawPath(
        Path()
          ..moveTo(x(250), y(31))
          ..lineTo(x(250), y(62))
          ..lineTo(x(268), y(33))
          ..close(),
        line,
      );

    // ----------------------------------------------------------- the cranes
    for (final base in [320.0, 360.0]) {
      canvas
        ..drawLine(Offset(x(base), y(26)), Offset(x(base), y(120)), line)
        ..drawLine(
          Offset(x(base - 22), y(112)),
          Offset(x(base + 30), y(126)),
          line,
        )
        ..drawLine(
          Offset(x(base + 30), y(126)),
          Offset(x(base + 30), y(104)),
          faint,
        );
    }
    // The quay containers under them.
    for (final c in [300.0, 316.0, 332.0, 348.0]) {
      canvas.drawRect(
        Rect.fromLTRB(x(c), y(40), x(c + 12), y(26)),
        faint,
      );
    }

    // ------------------------------------------------------------- the fort
    // Three towers with a gate between them, crenellated along the top.
    void tower(double left, double width, double height) {
      canvas.drawRect(
        Rect.fromLTRB(x(left), y(height), x(left + width), y(26)),
        line,
      );
      // Battlements: a run of small blocks along the parapet.
      final blocks = (width / 14).floor();
      for (var i = 0; i < blocks; i++) {
        final bx = left + 3 + i * 14;
        canvas.drawRect(
          Rect.fromLTRB(x(bx), y(height + 8), x(bx + 8), y(height)),
          line,
        );
      }
    }

    tower(470, 56, 96);
    tower(548, 62, 132);
    tower(622, 56, 96);

    // The gate: an arch in the middle tower.
    canvas.drawPath(
      Path()
        ..moveTo(x(566), y(26))
        ..lineTo(x(566), y(52))
        ..arcToPoint(Offset(x(592), y(52)), radius: Radius.circular(x(13)))
        ..lineTo(x(592), y(26)),
      line,
    );

    // The flag on the tallest tower.
    canvas
      ..drawLine(Offset(x(579), y(132)), Offset(x(579), y(168)), line)
      ..drawPath(
        Path()
          ..moveTo(x(579), y(168))
          ..lineTo(x(606), y(160))
          ..lineTo(x(579), y(152))
          ..close(),
        line,
      );

    // A low outwork to the left, so the fort sits on something.
    canvas.drawRect(Rect.fromLTRB(x(432), y(52), x(470), y(26)), faint);

    // ------------------------------------------------------------ the palms
    for (final p in [672.0, 700.0, 728.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(x(p), y(26))
          ..cubicTo(x(p + 2), y(60), x(p + 3), y(80), x(p + 2), y(96)),
        line,
      );
      for (final dir in [-1.0, 1.0]) {
        for (final spread in [0.55, 1.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(x(p + 2), y(96))
              ..cubicTo(
                x(p + 2 + dir * 10 * spread),
                y(104),
                x(p + 2 + dir * 20 * spread),
                y(102),
                x(p + 2 + dir * 26 * spread),
                y(90),
              ),
            line,
          );
        }
      }
    }

    // ---------------------------------------------------------- the minaret
    canvas
      ..drawRect(Rect.fromLTRB(x(770), y(120), x(786), y(26)), line)
      ..drawRect(Rect.fromLTRB(x(766), y(136), x(790), y(120)), line)
      ..drawPath(
        Path()
          ..moveTo(x(766), y(136))
          ..lineTo(x(778), y(158))
          ..lineTo(x(790), y(136))
          ..close(),
        line,
      );

    // ------------------------------------------------------------ the souq
    // A run of arcaded low buildings closing the composition.
    canvas.drawRect(Rect.fromLTRB(x(800), y(78), x(930), y(26)), line);
    for (var i = 0; i < 5; i++) {
      final ax = 812 + i * 24.0;
      canvas.drawPath(
        Path()
          ..moveTo(x(ax), y(26))
          ..lineTo(x(ax), y(48))
          ..arcToPoint(Offset(x(ax + 14), y(48)), radius: Radius.circular(x(7)))
          ..lineTo(x(ax + 14), y(26)),
        faint,
      );
    }
    canvas.drawRect(Rect.fromLTRB(x(930), y(58), x(1000), y(26)), faint);
  }

  @override
  bool shouldRepaint(_SkylinePainter old) =>
      old.color != color || old.opacity != opacity;
}

/// The soft green sweep across a top corner.
///
/// The counterweight to the skyline: the composition on the brand board is a
/// heavy corner above and a light horizon below, and the page needs both or it
/// reads as a drawing with a lot of empty paper over it.
class NamatCornerSweep extends StatelessWidget {
  const NamatCornerSweep({super.key, this.height = 240});

  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _SweepPainter()),
      ),
    );
  }
}

class _SweepPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Mirrored by the layout rather than by the painter, so the sweep sits in
    // the trailing corner in both directions without a second path.
    canvas.drawPath(
      Path()
        ..moveTo(w, 0)
        ..lineTo(w * 0.42, 0)
        ..cubicTo(w * 0.62, h * 0.36, w * 0.72, h * 0.62, w, h * 0.52)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            NamatColors.sage.withOpacity(0.34),
            NamatColors.sageLight.withOpacity(0.10),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // A hairline riding the same curve, which is what stops the shape reading
    // as a flat wash.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.42, 0)
        ..cubicTo(w * 0.62, h * 0.36, w * 0.72, h * 0.62, w, h * 0.52),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = NamatColors.sage.withOpacity(0.4),
    );
  }

  @override
  bool shouldRepaint(_SweepPainter old) => false;
}
