import 'package:flutter/material.dart';
import '../theme/namat_colors.dart';

/// Entry motion.
///
/// A list that appears fully formed reads as a screenshot; the same list
/// arriving in sequence reads as a product doing something. The effect is
/// deliberately small — 14 logical pixels and a fade — because the goal is for
/// a reader to feel the screen settle, not to watch it perform.
///
/// The stagger caps out after a few items. Delaying the ninth card by 9×60ms
/// means the bottom of a long list is still animating half a second after the
/// reader has scrolled to it, which turns a nicety into a wait.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.index = 0,
    this.step = const Duration(milliseconds: 55),
    this.offset = 14,
  });

  final Widget child;

  /// Position in the group. Later items start later.
  final int index;
  final Duration step;

  /// How far the child rises, in logical pixels.
  final double offset;

  /// Beyond this position everything shares the last delay.
  static const _maxStagger = 6;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: NamatMotion.slow,
  );

  @override
  void initState() {
    super.initState();
    final steps = widget.index.clamp(0, Reveal._maxStagger);
    final delay = widget.step * steps;
    if (delay == Duration.zero) {
      _c.forward();
    } else {
      Future<void>.delayed(delay, () {
        // The screen can be popped before the delay elapses.
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: NamatMotion.enter);

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - curved.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Wraps each child in a [Reveal] with its position already supplied.
List<Widget> revealAll(List<Widget> children, {int from = 0}) => [
      for (var i = 0; i < children.length; i++)
        Reveal(index: from + i, child: children[i]),
    ];

/// A press that answers.
///
/// Every tappable surface in the app scales very slightly under the finger.
/// It is the cheapest possible signal that a thing is interactive, and its
/// absence is most of what makes a Flutter screen feel like a web page.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: NamatMotion.fast,
        curve: NamatMotion.enter,
        child: widget.child,
      ),
    );
  }
}

/// The loading state: three leaves arriving in turn.
///
/// A spinner says only "wait". This says "NAMAT is working", takes the same
/// time, and is the one place in the app where motion exists purely to fill a
/// gap — so it is at least the brand's own gap-filler.
class NamatLoading extends StatefulWidget {
  const NamatLoading({super.key, this.size = 34});

  final double size;

  @override
  State<NamatLoading> createState() => _NamatLoadingState();
}

class _NamatLoadingState extends State<NamatLoading>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Opacity(
                  // Each leaf leads the next by a third of the cycle.
                  opacity: (((_c.value + i / 3) % 1) * 2).clamp(0.0, 1.0) > 1
                      ? 2 - (((_c.value + i / 3) % 1) * 2)
                      : ((_c.value + i / 3) % 1) * 2,
                  child: _Leaf(size: widget.size / 3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Leaf extends StatelessWidget {
  const _Leaf({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _LeafPainter()),
      );
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final path = Path()
      ..moveTo(w / 2, 0)
      ..cubicTo(w, w * 0.28, w * 0.86, w * 0.86, w / 2, w)
      ..cubicTo(w * 0.14, w * 0.86, 0, w * 0.28, w / 2, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = NamatColors.accent);
  }

  @override
  bool shouldRepaint(_LeafPainter old) => false;
}
