import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';

/// Order confirmed.
///
/// A leaf opens once and settles. Confetti would be the obvious choice and the
/// wrong one — this is a receipt, and a product about steady habits should not
/// throw a party for a transaction.
class OrderDonePage extends StatefulWidget {
  const OrderDonePage({super.key});

  @override
  State<OrderDonePage> createState() => _OrderDonePageState();
}

class _OrderDonePageState extends State<OrderDonePage>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(NamatSpace.gutter),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    final grow = Curves.easeOutBack.transform(
                      (_c.value * 1.4).clamp(0.0, 1.0),
                    );
                    return SizedBox.square(
                      dimension: 120,
                      child: CustomPaint(painter: _LeafPainter(grow)),
                    );
                  },
                ),
                const SizedBox(height: NamatSpace.xxl),
                Text(
                  l.orderPlaced,
                  style: text.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: NamatSpace.sm),
                Text(
                  l.orderPlacedBody,
                  style: text.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: NamatSpace.section),
                FilledButton(
                  onPressed: () => context.go('/home/bookings'),
                  child: Text(l.bookingsTitle),
                ),
                const SizedBox(height: NamatSpace.sm),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(l.backHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  _LeafPainter(this.t);

  /// 0–1 as the leaf opens.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    canvas.drawCircle(
      c,
      r * t,
      Paint()..color = NamatColors.greenSoft,
    );

    if (t < 0.25) return;

    // The leaf grows from its stem rather than scaling from the middle, so it
    // unfurls instead of inflating.
    final grow = ((t - 0.25) / 0.75).clamp(0.0, 1.0);
    final h = r * 1.05 * grow;
    final w = h * 0.52;
    final top = Offset(c.dx, c.dy + r * 0.5 - h);

    canvas.drawPath(
      Path()
        ..moveTo(top.dx, top.dy)
        ..cubicTo(top.dx + w, top.dy + h * 0.28, top.dx + w * 0.72,
            top.dy + h * 0.86, top.dx, top.dy + h)
        ..cubicTo(top.dx - w * 0.72, top.dy + h * 0.86, top.dx - w,
            top.dy + h * 0.28, top.dx, top.dy)
        ..close(),
      Paint()..color = NamatColors.accent,
    );
  }

  @override
  bool shouldRepaint(_LeafPainter old) => old.t != t;
}
