import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../core/l10n/numbers.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/field.dart';

/// "Use NAMAT" — the question before the catalogue.
///
/// Deliberately no search, no tabs, no filter chips. Those belong one level
/// down where they have a subject: filtering by "high protein" before choosing
/// between a gym and a dietitian is filtering nothing.
///
/// The cards carry illustrations built from the icon family rather than
/// photography — a stock picture of someone else's kitchen says nothing true
/// about a partner, and thirty-eight of them make the catalogue look like one
/// business repeated.
class UsePage extends StatelessWidget {
  const UsePage({super.key});

  /// Stand-in counts until the API is wired. Zero is a real state here and is
  /// rendered as such, not hidden.
  static const _counts = {
    NamatField.meals: 34,
    NamatField.fitness: 0,
    NamatField.consult: 0,
    NamatField.stores: 4,
  };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return NamatBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter, NamatSpace.xl, NamatSpace.gutter, 120,
          ),
          children: [
            Text(l.useGreeting, style: text.displayMedium),
            const SizedBox(height: NamatSpace.sm),
            Text(l.useSub, style: text.bodySmall),
            const SizedBox(height: NamatSpace.xxl),
            for (final field in NamatField.values) ...[
              _FieldCard(field: field, count: _counts[field] ?? 0),
              const SizedBox(height: NamatSpace.lg),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldCard extends StatefulWidget {
  const _FieldCard({required this.field, required this.count});

  final NamatField field;
  final int count;

  @override
  State<_FieldCard> createState() => _FieldCardState();
}

class _FieldCardState extends State<_FieldCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final empty = widget.count == 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () => context.go('/use/${widget.field.name}'),
      child: AnimatedScale(
        // A press that moves is the difference between a card and a picture.
        scale: _pressed ? 0.98 : 1,
        duration: NamatMotion.fast,
        curve: NamatMotion.enter,
        child: NamatCard(
          organic: true,
          color: widget.field.tint,
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 172,
            child: Stack(
              children: [
                // The illustration: the field's own icon, oversized and bled
                // off the corner so it reads as a composition rather than a
                // logo sitting in a box.
                PositionedDirectional(
                  end: -18,
                  bottom: -14,
                  child: Opacity(
                    opacity: 0.18,
                    child: NamatIcon(
                      widget.field.icon,
                      size: 148,
                      color: widget.field.accent,
                    ),
                  ),
                ),
                PositionedDirectional(
                  end: 26,
                  top: 22,
                  child: Hero(
                    tag: 'field-${widget.field.name}',
                    child: NamatIcon(
                      widget.field.icon,
                      size: 40,
                      color: widget.field.accent,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(NamatSpace.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: empty
                              ? NamatColors.ink.withOpacity(0.08)
                              : NamatColors.surface,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          empty
                              ? l.noPartnersYet
                              : l.optionCount(context.n(widget.count)),
                          style: text.labelSmall?.copyWith(
                            color: empty
                                ? NamatColors.inkSoft
                                : widget.field.accent,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.field.title(l),
                        style: text.titleLarge?.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 2),
                      Text(widget.field.subtitle(l), style: text.bodySmall),
                      const SizedBox(height: NamatSpace.md),
                      Row(
                        children: [
                          Text(
                            l.explore,
                            style: text.labelMedium?.copyWith(
                              color: widget.field.accent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: widget.field.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
