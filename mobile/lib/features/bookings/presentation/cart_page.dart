import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/booking.dart';

/// One cart for the whole ecosystem.
///
/// A meal, a consultation and a supplement check out together because from the
/// member's side they are one evening's decisions. Three separate payment
/// flows for one intent is exactly the friction NAMAT exists to remove.
///
/// Lines an allowance covers keep their real price, struck through, with the
/// saving named. A line silently reading zero hides what the package is worth,
/// which is the one number that justifies renewing it.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _items = const [
    CartItem(
      id: '1',
      kind: BookingKind.order,
      title: 'وجبة غداء متوازنة',
      partner: 'مطعم المعمل الصحي',
      price: 3.5,
      quantity: 2,
      coveredByPackage: true,
    ),
    CartItem(
      id: '2',
      kind: BookingKind.consultation,
      title: 'استشارة تغذية · ٤٥ دقيقة',
      partner: 'عيادة دانة للتغذية',
      price: 15,
    ),
    CartItem(
      id: '3',
      kind: BookingKind.order,
      title: 'بروتين واي · ٢ كجم',
      partner: 'Tree of Life',
      price: 22.5,
    ),
  ];

  void _remove(String id) =>
      setState(() => _items = _items.where((i) => i.id != id).toList());

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final totals = CartTotals(_items);

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
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
                  220,
                ),
                children: revealAll([
                  for (final item in _items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: NamatSpace.md),
                      child: _Line(
                        item: item,
                        onRemove: () => _remove(item.id),
                      ),
                    ),
                ]),
              ),
        bottomSheet: totals.isEmpty
            ? null
            : _Summary(totals: totals, onCheckout: () => context.go('/cart/done')),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.item, required this.onRemove});

  final CartItem item;
  final VoidCallback onRemove;

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
                Row(
                  children: [
                    if (item.quantity > 1) ...[
                      Text('×${context.n(item.quantity)}',
                          style: text.labelSmall),
                      const SizedBox(width: 10),
                    ],
                    // The real price stays visible even when covered — that
                    // number is what makes the package worth renewing.
                    Text(
                      '${context.n(item.lineTotal)} ${l.omr}',
                      style: text.labelMedium?.copyWith(
                        color: item.coveredByPackage
                            ? NamatColors.inkSoft
                            : NamatColors.ink,
                        decoration: item.coveredByPackage
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (item.coveredByPackage) ...[
                      const SizedBox(width: 8),
                      Text(
                        l.freeFromPackage,
                        style: text.labelSmall
                            ?.copyWith(color: NamatColors.accent),
                      ),
                    ],
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
          _Row(label: l.subtotal, value: '${context.n(totals.subtotal)} ${l.omr}'),
          if (totals.covered > 0) ...[
            const SizedBox(height: 6),
            _Row(
              label: l.packageCovers,
              value: '−${context.n(totals.covered)} ${l.omr}',
              colour: NamatColors.accent,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: NamatSpace.md),
            child: Divider(height: 1),
          ),
          _Row(
            label: l.youPay,
            value: '${context.n(totals.payable)} ${l.omr}',
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
