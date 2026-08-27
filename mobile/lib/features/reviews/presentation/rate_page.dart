import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../bookings/domain/cart_notifier.dart';
import '../../rewards/domain/points.dart';

/// Rating an order.
///
/// Stars first and alone. Tags and a note appear only after a star is chosen,
/// because a screen that opens with three questions gets none of them answered
/// — and because which tags are worth offering depends on whether the member
/// is about to praise something or complain about it.
class RatePage extends ConsumerStatefulWidget {
  const RatePage({super.key, required this.reference});

  final String reference;

  @override
  ConsumerState<RatePage> createState() => _RatePageState();
}

class _RatePageState extends ConsumerState<RatePage> {
  int _stars = 0;
  final _tags = <String>{};
  final _note = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    ref.read(ordersProvider.notifier).rate(widget.reference, _stars);
    ref
        .read(pointsProvider.notifier)
        .award(PointsReason.review, detail: widget.reference);
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final order = ref
        .watch(ordersProvider)
        .where((o) => o.reference == widget.reference)
        .firstOrNull;

    if (order == null) {
      return NamatBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: const NamatBack(fallback: '/bookings'),
          ),
          body: NamatEmptyState(title: l.errorTitle, body: l.errorBody),
        ),
      );
    }

    if (_sent) {
      return _Thanks(stars: _stars);
    }

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const NamatBack(fallback: '/bookings'),
          actions: [
            // Always available. A rating screen with no way out is how you
            // collect ratings nobody meant to give.
            TextButton(
              onPressed: () => context.go('/bookings'),
              child: Text(l.rateLater),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.sm,
            NamatSpace.gutter,
            160,
          ),
          children: revealAll([
            Text(l.rateTitle, style: text.displayMedium),
            const SizedBox(height: NamatSpace.sm),
            Text(l.rateBody, style: text.bodySmall),
            const SizedBox(height: NamatSpace.xl),
            NamatCard(
              padding: const EdgeInsets.all(NamatSpace.lg),
              child: Row(
                children: [
                  const NamatIcon(
                    NamatIcons.partner,
                    size: 22,
                    color: NamatColors.inkSoft,
                  ),
                  const SizedBox(width: NamatSpace.md),
                  Expanded(
                    child: Text(
                      l.rateOrderLine(
                        order.leadTitle,
                        order.items.first.partner,
                      ),
                      style: text.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NamatSpace.xxl),
            _Stars(
              value: _stars,
              onChanged: (v) => setState(() => _stars = v),
            ),
            const SizedBox(height: NamatSpace.md),
            Center(
              child: AnimatedSwitcher(
                duration: NamatMotion.fast,
                child: Text(
                  _stars == 0 ? '' : _starWord(_stars, l),
                  key: ValueKey(_stars),
                  style: text.labelMedium?.copyWith(
                    color: NamatColors.deep,
                  ),
                ),
              ),
            ),
            // Everything below waits for a star. Asking what went well before
            // knowing whether anything did is a leading question.
            if (_stars > 0) ...[
              const SizedBox(height: NamatSpace.xxl),
              Text(l.rateWhatWorked, style: text.labelMedium),
              const SizedBox(height: NamatSpace.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _tagsFor(l))
                    _TagPill(
                      label: t,
                      selected: _tags.contains(t),
                      onTap: () => setState(() {
                        _tags.contains(t) ? _tags.remove(t) : _tags.add(t);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: NamatSpace.xl),
              TextField(
                controller: _note,
                maxLines: 3,
                decoration: InputDecoration(hintText: l.rateNoteHint),
              ),
            ],
          ]),
        ),
        bottomSheet: Container(
          color: NamatColors.canvas,
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.md,
            NamatSpace.gutter,
            NamatSpace.xxl,
          ),
          child: FilledButton(
            onPressed: _stars == 0 ? null : _submit,
            child: Text(l.rateSubmit),
          ),
        ),
      ),
    );
  }

  /// The same six tags either way.
  ///
  /// Offering "what went wrong" wording on a low rating and "what went well"
  /// on a high one produces two datasets that cannot be compared, and the
  /// partner reading them cannot tell whether "الطعم" was praise or a
  /// complaint. The star carries the sentiment; the tag carries the subject.
  List<String> _tagsFor(L l) => [
        l.tagTaste,
        l.tagPortion,
        l.tagOnTime,
        l.tagStaff,
        l.tagCleanliness,
        l.tagValue,
      ];

  static String _starWord(int stars, L l) => switch (stars) {
        1 => l.star1,
        2 => l.star2,
        3 => l.star3,
        4 => l.star4,
        _ => l.star5,
      };
}

class _Stars extends StatelessWidget {
  const _Stars({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          Pressable(
            onTap: () => onChanged(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: AnimatedScale(
                scale: value >= i ? 1.0 : 0.86,
                duration: NamatMotion.fast,
                curve: NamatMotion.enter,
                child: Icon(
                  value >= i ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 44,
                  color: value >= i ? NamatColors.gold : NamatColors.line,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: NamatMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? NamatColors.deep : NamatColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? NamatColors.deep : NamatColors.line,
          ),
        ),
        child: Text(
          label,
          style: text.labelMedium?.copyWith(
            color: selected ? Colors.white : NamatColors.ink,
          ),
        ),
      ),
    );
  }
}

class _Thanks extends StatelessWidget {
  const _Thanks({required this.stars});

  final int stars;

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
              children: revealAll([
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 1; i <= stars; i++)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(
                          Icons.star_rounded,
                          size: 30,
                          color: NamatColors.gold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: NamatSpace.xl),
                Text(
                  l.rateThanks,
                  style: text.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: NamatSpace.sm),
                Text(
                  l.rateThanksBody,
                  style: text.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: NamatSpace.section),
                FilledButton(
                  onPressed: () => context.go('/bookings'),
                  child: Text(l.bookingsTitle),
                ),
                const SizedBox(height: NamatSpace.sm),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(l.backHome),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
