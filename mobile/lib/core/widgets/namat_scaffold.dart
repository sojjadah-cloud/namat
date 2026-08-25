import 'package:flutter/material.dart';
import '../theme/namat_colors.dart';

/// The soft background every screen sits on.
///
/// Two blurred blooms rather than a flat fill: large areas of one colour go
/// dead on a phone, and a gradient this subtle reads as depth rather than as
/// decoration. Kept far below the content in opacity so text contrast is
/// unaffected wherever it lands.
class NamatBackground extends StatelessWidget {
  const NamatBackground({super.key, required this.child, this.bloom = true});

  final Widget child;
  final bool bloom;

  @override
  Widget build(BuildContext context) {
    if (!bloom) return child;

    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.85),
                radius: 1.1,
                colors: [Color(0x33A8C699), Color(0x00A8C699)],
              ),
            ),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.9, 0.35),
                radius: 0.9,
                colors: [Color(0x40F2E9D8), Color(0x00F2E9D8)],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// A surface with an asymmetric corner — the organic card from the spec.
///
/// One corner is cut larger than the rest, which is enough to stop a column of
/// these reading as a stack of identical rectangles without becoming a shape
/// that fights its own content.
class NamatCard extends StatelessWidget {
  const NamatCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(NamatSpace.xl),
    this.color = NamatColors.surface,
    this.organic = false,
    this.elevated = true,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final bool organic;
  final bool elevated;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    const r = Radius.circular(NamatRadius.lg);
    const big = Radius.circular(NamatRadius.organic + 6);

    final shape = organic
        ? BorderRadius.only(
            topLeft: rtl ? big : r,
            topRight: rtl ? r : big,
            bottomLeft: r,
            bottomRight: r,
          )
        : BorderRadius.circular(NamatRadius.lg);

    return Material(
      color: color,
      borderRadius: shape,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: shape,
            boxShadow: elevated
                ? const [
                    BoxShadow(
                      color: Color(0x0F2F4F4A),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Empty states, in the brand's voice: what is true, then what to do about it.
class NamatEmptyState extends StatelessWidget {
  const NamatEmptyState({
    super.key,
    required this.title,
    this.body,
    this.action,
    this.illustration,
  });

  final String title;
  final String? body;
  final Widget? action;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NamatSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null) ...[
              illustration!,
              const SizedBox(height: NamatSpace.xl),
            ],
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: NamatSpace.sm),
              Text(body!, style: text.bodySmall, textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: NamatSpace.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
