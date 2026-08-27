import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/booking.dart';
import '../domain/cart_notifier.dart';

/// One cart for the whole ecosystem.
///
/// A meal, a consultation and a supplement check out together because from the
/// member's side they are one evening's decisions. Three separate payment
/// flows for one intent is exactly the friction NAMAT exists to remove.
///
/// Lines an allowance covers keep their real price, struck through, with the
/// saving named. A line silently reading zero hides what the package is worth,
/// which is the one number that justifies renewing it.
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final items = ref.watch(cartProvider);
    final totals = ref.watch(cartTotalsProvider);
    final cart = ref.read(cartProvider.notifier);

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.canPop() ? context.pop() : context.go('/use'),
            icon: const Icon(Icons.arrow_forward),
          ),
          title: Text(l.cartTitle),
        ),
        body: totals.isEmpty
            ? NamatEmptyState(
                illustration: const NamatIcon(
                  NamatIcons.store,
                  size: 52,
                  color: NamatColors.inkSoft,
                ),
                title: l.cartEmpty,
                body: l.cartEmptyBody,
                action: FilledButton(
                  onPressed: () => context.go('/use'),
                  child: Text(l.cartBrowse),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  NamatSpace.gutter,
                  NamatSpace.lg,
                  NamatSpace.gutter,
                  240,
                ),
                children: revealAll([
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: NamatSpace.md),
                      child: _Line(
                        item: item,
                        onRemove: () => cart.remove(item.id),
                        onQuantity: (q) => cart.setQuantity(item.id, q),
                      ),
                    ),
                ]),
              ),
        bottomSheet: totals.isEmpty
            ? null
            : _Summary(
                totals: totals,
                // Checkout, not "done": the previous button skipped straight
                // past paying, which is the step that decides what the member
                // is actually charged.
                onCheckout: () => context.go('/cart/checkout'),
              ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.item,
    required this.onRemove,
    required this.onQuantity,
  });

  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantity;

  static const _icons = {
    BookingKind.order: NamatIcons.meals,
    BookingKind.consultation: NamatIcons.consultation,
    BookingKind.session: NamatIcons.fitness,
    BookingKind.subscription: NamatIcons.package,
  };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return NamatCard(
      padding: const EdgeInsets.all(NamatSpace.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NamatIcon(
            _icons[item.kind]!,
            size: 24,
            color: item.coveredByPackage
                ? NamatColors.accent
                : NamatColors.inkSoft,
          ),
          const SizedBox(width: NamatSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: text.titleMedium),
                const SizedBox(height: 2),
                Text(item.partner, style: text.bodySmall),
                const SizedBox(height: 8),
                // Wrap: the stepper, the price and the package note are 125
                // pixels too wide together at 360dp, and a Row clips the note
                // — which is the one that explains why the price is struck
                // through.
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Editable rather than a label. Changing your mind about
                    // a quantity is the commonest thing anyone does in a
                    // cart, and removing plus re-adding is not a fix.
                    _Quantity(value: item.quantity, onChanged: onQuantity),
                    // The real price stays visible even when covered — that
                    // number is what makes the package worth renewing.
                    Text(
                      '${context.money(item.lineTotal)} ${l.omr}',
                      style: text.labelMedium?.copyWith(
                        color: item.coveredByPackage
                            ? NamatColors.inkSoft
                            : NamatColors.ink,
                        decoration: item.coveredByPackage
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (item.coveredByPackage)
                      Text(
                        l.freeFromPackage,
                        style: text.labelSmall
                            ?.copyWith(color: NamatColors.accent),
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: l.removeItem,
            icon: const Icon(
              Icons.close,
              size: 18,
              color: NamatColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.totals, required this.onCheckout});

  final CartTotals totals;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        NamatSpace.gutter,
        NamatSpace.xl,
        NamatSpace.gutter,
        NamatSpace.xxl,
      ),
      decoration: const BoxDecoration(
        color: NamatColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NamatRadius.organic),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x142F4F4A), blurRadius: 24, offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Row(label: l.subtotal, value: '${context.money(totals.subtotal)} ${l.omr}'),
          if (totals.covered > 0) ...[
            const SizedBox(height: 6),
            _Row(
              label: l.packageCovers,
              value: '−${context.money(totals.covered)} ${l.omr}',
              colour: NamatColors.accent,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: NamatSpace.md),
            child: Divider(height: 1),
          ),
          _Row(
            label: l.youPay,
            value: '${context.money(totals.payable)} ${l.omr}',
            bold: true,
          ),
          const SizedBox(height: NamatSpace.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onCheckout, child: Text(l.checkout)),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.colour,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? colour;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final style = bold
        ? text.titleMedium
        : text.bodySmall?.copyWith(color: colour ?? NamatColors.inkSoft);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style?.copyWith(color: colour ?? style.color)),
      ],
    );
  }
}

class _Quantity extends StatelessWidget {
  const _Quantity({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget step(IconData icon, int to) => InkResponse(
          onTap: () => onChanged(to),
          radius: 18,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(icon, size: 16, color: NamatColors.deep),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: NamatColors.warmSoft,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // At one, the minus removes the line. Anything else leaves a zero
          // sitting in the cart that the member then has to deal with twice.
          step(value > 1 ? Icons.remove : Icons.delete_outline, value - 1),
          SizedBox(
            width: 22,
            child: Text(
              context.n(value),
              textAlign: TextAlign.center,
              style: text.labelMedium,
            ),
          ),
          step(Icons.add, value + 1),
        ],
      ),
    );
  }
}
