import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../core/widgets/namat_states.dart';
import '../../../l10n/app_localizations.dart';
import '../../account/domain/session.dart';
import '../../catalogue/domain/catalogue.dart';
import '../../rewards/domain/points.dart';
import '../domain/booking.dart';
import '../domain/cart_notifier.dart';
import '../domain/order.dart';

/// Checkout: how it reaches you, when, and how it is paid for.
///
/// The three questions are asked together on one screen rather than as a
/// wizard. A cart is already a decision the member has made; splitting the
/// last step into three pages is where carts get abandoned.
///
/// Which questions appear depends on what is in the cart, not on a fixed
/// template — a cart of consultations has nothing to deliver, and asking for
/// an address anyway is how a form teaches people it is not paying attention.
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  Fulfilment? _fulfilment;
  PaymentMethod? _method;
  DateTime? _slot;
  final _address = TextEditingController();
  bool _addressMissing = false;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  /// The fulfilment choices this particular cart supports.
  List<Fulfilment> _optionsFor(List<CartItem> items) {
    final kinds = items
        .map((i) => Catalogue.offeringById(i.id)?.kind)
        .whereType<OfferingKind>()
        .toSet();

    final physical = kinds.any((k) => k.needsFulfilment);
    final attended = kinds.any((k) => k.needsSlot);

    return [
      if (physical) Fulfilment.delivery,
      if (physical) Fulfilment.pickup,
      if (attended) Fulfilment.atPartner,
      if (attended) Fulfilment.online,
    ];
  }

  bool _needsSlot(List<CartItem> items) => items.any(
        (i) => Catalogue.offeringById(i.id)?.kind.needsSlot ?? false,
      );

  /// The times a member can actually be given.
  ///
  /// Taken from the timetable of whatever in the cart needs a time, so a
  /// Tuesday-and-Thursday class offers Tuesdays and Thursdays rather than the
  /// next six hours. Where several booked things have timetables, only the
  /// times they all share are offered — a slot that suits one and clashes
  /// with the other is not a slot.
  List<DateTime> _slots(List<CartItem> items) {
    final now = DateTime.now();

    final timetabled = <List<DateTime>>[];
    var anyNeedsSlot = false;
    for (final i in items) {
      final o = Catalogue.offeringById(i.id);
      if (o == null || !o.kind.needsSlot) continue;
      anyNeedsSlot = true;
      final times = o.availability?.upcoming(now, count: 8) ?? const [];
      if (times.isNotEmpty) timetabled.add(times);
    }
    if (!anyNeedsSlot) return const [];

    // Nothing booked publishes a timetable, so fall back to open hours on the
    // half hour. Offered as choices, and the screen says they are not
    // confirmed until the partner accepts.
    if (timetabled.isEmpty) {
      var first = DateTime(now.year, now.month, now.day, now.hour + 2);
      first = first.add(Duration(minutes: 30 - (first.minute % 30)));
      return [for (var i = 0; i < 6; i++) first.add(Duration(hours: i * 3))];
    }

    var shared = timetabled.first.toSet();
    for (final other in timetabled.skip(1)) {
      shared = shared.intersection(other.toSet());
    }
    // No overlap at all: rather than offering nothing, offer the soonest
    // service's times and let the member book the other separately.
    final chosen = shared.isEmpty ? timetabled.first.toSet() : shared;
    return chosen.toList()..sort();
  }

  /// The prompt a guest meets here and nowhere earlier.
  ///
  /// Everything up to this point — every partner, every price, every
  /// timetable — was readable without an account. Placing the order is the
  /// first thing that creates an obligation, so it is the first thing that
  /// asks who is doing it.
  void _promptSignIn() {
    final l = L.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: NamatColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NamatRadius.organic),
        ),
      ),
      builder: (sheet) => NamatSignInPrompt(
        title: l.signInToOrder,
        onSignIn: () {
          Navigator.of(sheet).pop();
          context.go('/login');
        },
        onDismiss: () => Navigator.of(sheet).pop(),
      ),
    );
  }

  void _place(List<CartItem> items, CartTotals totals) {
    if (ref.read(sessionProvider).isGuest) return _promptSignIn();

    final needsAddress = _fulfilment == Fulfilment.delivery;
    if (needsAddress && _address.text.trim().isEmpty) {
      setState(() => _addressMissing = true);
      return;
    }

    final order = PlacedOrder(
      reference: makeReference(),
      items: items,
      placedAt: DateTime.now(),
      method: _method ?? PaymentMethod.allowance,
      fulfilment: _fulfilment ?? Fulfilment.pickup,
      paid: totals.payable,
      covered: totals.covered,
      slot: _slot,
      address: needsAddress ? _address.text.trim() : null,
    );

    // Which partners are new has to be read before the order is placed, or
    // the order being placed makes every one of them look familiar.
    final seen = {
      for (final o in ref.read(ordersProvider))
        for (final i in o.items) i.partner,
    };

    ref.read(ordersProvider.notifier).place(order);

    // Earned for finishing something, not for spending. Awarding by value
    // would make the programme a discount on large orders, which rewards a
    // burst rather than the continuing this product is about.
    final points = ref.read(pointsProvider.notifier)
      ..award(PointsReason.order, detail: order.reference);

    // And once per partner, ever — trying somewhere new is the behaviour
    // worth paying for; going back is already its own reward.
    for (final partner in {for (final i in items) i.partner}) {
      if (partner.isEmpty || seen.contains(partner)) continue;
      points.awardOnce(PointsReason.newPartner, detail: partner);
    }
    ref.read(cartProvider.notifier).clear();
    context.go('/cart/done/${order.reference}');
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final items = ref.watch(cartProvider);
    final totals = ref.watch(cartTotalsProvider);

    // Reaching checkout with nothing in the cart means the order was placed in
    // another tab, or the member came back on the history stack.
    if (items.isEmpty) {
      return NamatBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(),
          body: NamatEmptyState(
            title: l.cartEmpty,
            body: l.cartEmptyBody,
            action: FilledButton(
              onPressed: () => context.go('/explore'),
              child: Text(l.cartBrowse),
            ),
          ),
        ),
      );
    }

    final options = _optionsFor(items);
    final needsSlot = _needsSlot(items);
    final free = totals.payable == 0;

    // A cart the package covers entirely has nothing to charge, so the payment
    // question is not asked at all rather than asked and ignored.
    final methods = free
        ? const <PaymentMethod>[]
        : const [
            PaymentMethod.card,
            PaymentMethod.applePay,
            PaymentMethod.cash,
          ];

    final ready = (options.isEmpty || _fulfilment != null) &&
        (!needsSlot || _slot != null) &&
        (free || _method != null);

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const NamatBack(fallback: '/cart'),
          title: Text(l.checkoutTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.sm,
            NamatSpace.gutter,
            200,
          ),
          children: revealAll([
            if (options.isNotEmpty) ...[
              Text(l.howToReceive, style: text.labelMedium),
              const SizedBox(height: NamatSpace.md),
              for (final f in options)
                _Choice(
                  label: _fulfilmentLabel(f, l),
                  icon: _fulfilmentIcon(f),
                  selected: _fulfilment == f,
                  onTap: () => setState(() => _fulfilment = f),
                ),
              if (_fulfilment == Fulfilment.delivery) ...[
                const SizedBox(height: NamatSpace.md),
                TextField(
                  controller: _address,
                  maxLines: 2,
                  onChanged: (_) {
                    if (_addressMissing) {
                      setState(() => _addressMissing = false);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: l.deliveryAddress,
                    hintText: l.addressHint,
                    errorText: _addressMissing ? l.addressRequired : null,
                  ),
                ),
              ],
              const SizedBox(height: NamatSpace.xxl),
            ],
            if (needsSlot) ...[
              Text(l.chooseTime, style: text.labelMedium),
              const SizedBox(height: NamatSpace.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in _slots(items))
                    _SlotPill(
                      label: context.dateTime(s),
                      selected: _slot == s,
                      onTap: () => setState(() => _slot = s),
                    ),
                ],
              ),
              const SizedBox(height: NamatSpace.xxl),
            ],
            if (methods.isNotEmpty) ...[
              Text(l.payWith, style: text.labelMedium),
              const SizedBox(height: NamatSpace.md),
              for (final m in methods)
                _Choice(
                  label: _methodLabel(m, l),
                  icon: _methodIcon(m),
                  selected: _method == m,
                  onTap: () => setState(() => _method = m),
                ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(NamatSpace.lg),
                decoration: BoxDecoration(
                  color: NamatColors.greenSoft,
                  borderRadius: BorderRadius.circular(NamatRadius.sm),
                ),
                child: Row(
                  children: [
                    const NamatIcon(
                      NamatIcons.leaf,
                      size: 18,
                      color: NamatColors.accent,
                      filled: true,
                    ),
                    const SizedBox(width: NamatSpace.sm),
                    Expanded(
                      child: Text(
                        l.nothingDue,
                        style: text.bodySmall
                            ?.copyWith(color: NamatColors.deeper),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: NamatSpace.xxl),
            Text(l.orderSummary, style: text.labelMedium),
            const SizedBox(height: NamatSpace.md),
            NamatCard(
              padding: const EdgeInsets.all(NamatSpace.lg),
              child: Column(
                children: [
                  for (final i in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              i.quantity > 1
                                  ? '${i.title} ×${context.n(i.quantity)}'
                                  : i.title,
                              style: text.bodySmall,
                            ),
                          ),
                          Text(
                            i.coveredByPackage
                                ? l.freeFromPackage
                                : '${context.money(i.lineTotal)} ${l.omr}',
                            style: text.labelSmall?.copyWith(
                              color: i.coveredByPackage
                                  ? NamatColors.accent
                                  : NamatColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: NamatSpace.sm),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      Expanded(child: Text(l.youPay, style: text.labelMedium)),
                      Text(
                        '${context.money(totals.payable)} ${l.omr}',
                        style: text.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: NamatSpace.lg),
            // Said plainly and before the button, not after the tap. No
            // provider is connected; pretending otherwise would make a member
            // believe a card had been charged.
            if (!free)
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 15,
                    color: NamatColors.inkSoft,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(l.demoPayment, style: text.labelSmall),
                  ),
                ],
              ),
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
            onPressed: ready ? () => _place(items, totals) : null,
            child: Text(
              free
                  ? l.confirmOrder
                  : l.payNow(context.money(totals.payable), l.omr),
            ),
          ),
        ),
      ),
    );
  }

  static String _fulfilmentLabel(Fulfilment f, L l) => switch (f) {
        Fulfilment.delivery => l.fulfilDelivery,
        Fulfilment.pickup => l.fulfilPickup,
        Fulfilment.atPartner => l.fulfilAtPartner,
        Fulfilment.online => l.fulfilOnline,
      };

  static IconData _fulfilmentIcon(Fulfilment f) => switch (f) {
        Fulfilment.delivery => Icons.delivery_dining,
        Fulfilment.pickup => Icons.storefront,
        Fulfilment.atPartner => Icons.place_outlined,
        Fulfilment.online => Icons.videocam_outlined,
      };

  static String _methodLabel(PaymentMethod m, L l) => switch (m) {
        PaymentMethod.card => l.payCard,
        PaymentMethod.applePay => l.payApplePay,
        PaymentMethod.cash => l.payCash,
        PaymentMethod.allowance => l.payAllowance,
      };

  static IconData _methodIcon(PaymentMethod m) => switch (m) {
        PaymentMethod.card => Icons.credit_card,
        PaymentMethod.applePay => Icons.phone_iphone,
        PaymentMethod.cash => Icons.payments_outlined,
        PaymentMethod.allowance => Icons.card_giftcard,
      };
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: NamatSpace.sm),
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: NamatMotion.fast,
          curve: NamatMotion.enter,
          padding: const EdgeInsets.all(NamatSpace.lg),
          decoration: BoxDecoration(
            color: selected ? NamatColors.greenSoft : NamatColors.surface,
            borderRadius: BorderRadius.circular(NamatRadius.sm),
            border: Border.all(
              color: selected ? NamatColors.deep : NamatColors.line,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? NamatColors.deep : NamatColors.inkSoft,
              ),
              const SizedBox(width: NamatSpace.md),
              Expanded(child: Text(label, style: text.bodyMedium)),
              AnimatedScale(
                scale: selected ? 1 : 0,
                duration: NamatMotion.fast,
                curve: NamatMotion.enter,
                child: const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: NamatColors.deep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotPill extends StatelessWidget {
  const _SlotPill({
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
