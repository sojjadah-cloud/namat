import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/namat_colors.dart';
import 'namat_icon.dart';

/// Generated artwork for a thing that has no photograph.
///
/// Every product, dish and session in the catalogue is a row of text, because
/// NAMAT has no photography and will not use stock: a picture of somebody
/// else's salad standing in for a partner's dish is a claim about that dish.
/// But a list of text rows is genuinely hard to scan — the eye has nothing to
/// land on, and every item looks like every other item.
///
/// So each one gets a mark drawn from its own identifier: the same id always
/// produces the same composition, different ids produce visibly different
/// ones, and the palette comes from the field it belongs to. Nothing here
/// depicts the product. It is a token that makes a list scannable and tells
/// the truth about how much we know, which is nothing.
class NamatArt extends StatelessWidget {
  const NamatArt({
    super.key,
    required this.seed,
    required this.accent,
    required this.tint,
    this.icon,
    this.size = 62,
    this.radius = NamatRadius.xs,
  });

  /// Usually the offering id or the partner slug. Identical seeds draw
  /// identical marks, which matters: a dish that changes its appearance
  /// between the list and the sheet reads as a different dish.
  final String seed;

  final Color accent;
  final Color tint;

  /// Drawn over the composition. The field's own glyph, so a member can tell a
  /// class from a meal at a glance without reading either.
  final NamatIcons? icon;

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          painter: _ArtPainter(seed: seed, accent: accent, tint: tint),
          child: icon == null
              ? null
              : Center(
                  child: NamatIcon(
                    icon!,
                    size: size * 0.36,
                    color: accent,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  _ArtPainter({
    required this.seed,
    required this.accent,
    required this.tint,
  });

  final String seed;
  final Color accent;
  final Color tint;

  /// A stable hash of the seed.
  ///
  /// `String.hashCode` is not stable across runs in Dart, so a dish would be
  /// one shape today and another after a restart. Written out for that reason
  /// rather than for speed.
  int get _seedValue {
    var h = 2166136261;
    for (final unit in seed.codeUnits) {
      h = (h ^ unit) * 16777619 & 0x7fffffff;
    }
    return h;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(_seedValue);
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = tint);

    // Two or three arcs sweeping across the tile, at the field's accent held
    // well back. They read as texture rather than as a picture of anything —
    // which is the point: this is a token, not a depiction.
    final strokes = 2 + random.nextInt(2);
    for (var i = 0; i < strokes; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * (0.05 + random.nextDouble() * 0.06)
        ..strokeCap = StrokeCap.round
        ..color = accent.withOpacity(0.13 + random.nextDouble() * 0.12);

      final startY = h * (0.15 + random.nextDouble() * 0.7);
      final endY = h * (0.15 + random.nextDouble() * 0.7);
      canvas.drawPath(
        Path()
          ..moveTo(-w * 0.1, startY)
          ..cubicTo(
            w * 0.3,
            h * random.nextDouble(),
            w * 0.7,
            h * random.nextDouble(),
            w * 1.1,
            endY,
          ),
        paint,
      );
    }

    // One soft disc, off centre, so the composition has a weight to it.
    canvas.drawCircle(
      Offset(w * (0.2 + random.nextDouble() * 0.6),
          h * (0.2 + random.nextDouble() * 0.6)),
      w * (0.14 + random.nextDouble() * 0.12),
      Paint()..color = accent.withOpacity(0.10),
    );
  }

  @override
  bool shouldRepaint(_ArtPainter old) =>
      old.seed != seed || old.accent != accent || old.tint != tint;
}
