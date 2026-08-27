import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/booking.dart';
import '../domain/cart_notifier.dart';
import '../domain/order.dart';

/// Everything NAMAT owes the member, in one place.
///
/// Three tabs rather than one list, because the questions differ: "what is
/// happening next", "what am I still paying for", and "what did I do". A
/// single chronological list answers the first well and the other two badly.
class BookingsPage extends ConsumerStatefulWidget {
  const BookingsPage({super.key});

  @override
  ConsumerState<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends ConsumerState<BookingsPage>
    with SingleTickerProviderStateMixin {
  // Four, not three. An order placed a minute ago is neither upcoming nor
  // past, and filing it under either makes the member distrust both lists.
  late final TabController _tabs = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  /// One booking per line of every order.
  ///
  /// An order is one act of paying; a booking is one thing NAMAT owes. Buying
  /// a week of meals and a class in a single checkout is one order and two
  /// bookings, and collapsing them would leave the member unable to see what
  /// is happening on Tuesday.
  static List<Booking> _fromOrders(List<PlacedOrder> orders) {
    final now = DateTime.now();
    return [
      for (final o in orders)
        for (final item in o.items)
          Booking(
            id: '${o.reference}-${item.id}',
            kind: item.kind,
            title: item.title,
            partner: item.partner,
            at: o.slot,
            state: switch (item.kind) {
              // A subscription runs rather than happening at a moment.
              BookingKind.subscription => BookingState.active,
              // Anything with a time is upcoming until that time passes.
              _ when o.slot != null && o.slot!.isAfter(now) =>
                BookingState.upcoming,
              _ => BookingState.completed,
            },
            coveredByPackage: item.coveredByPackage,
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    // Derived from what the member actually placed. There used to be five
    // sample bookings here, which meant a brand-new account opened onto
    // someone else's reformer class — the single most confusing thing an
    // empty app can do.
    final bookings = _fromOrders(ref.watch(ordersProvider));
    final upcoming = bookings
        .where((b) => !b.isSubscription && b.state == BookingState.upcoming)
        .toList();
    final subs = bookings.where((b) => b.isSubscription).toList();
    final past = bookings.where((b) => b.isPast).toList();

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const NamatBack(),
          title: Text(l.bookingsTitle),
          bottom: TabBar(
            controller: _tabs,
            labelColor: NamatColors.deep,
            unselectedLabelColor: NamatColors.inkSoft,
            indicatorColor: NamatColors.deep,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: text.labelMedium,
            tabs: [
              Tab(text: l.tabUpcoming),
              Tab(text: l.tabSubscriptions),
              Tab(text: l.tabPast),
              Tab(text: l.recentOrders),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: [
            _List(
              bookings: upcoming,
              emptyTitle: l.noUpcoming,
              emptyBody: l.noUpcomingBody,
            ),
            _List(bookings: subs, emptyTitle: l.noSubscriptions),
            _List(bookings: past, emptyTitle: l.noPast),
            _Orders(orders: ref.watch(ordersProvider)),
          ],
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.bookings,
    required this.emptyTitle,
    this.emptyBody,
  });

  final List<Booking> bookings;
  final String emptyTitle;
  final String? emptyBody;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;

    if (bookings.isEmpty) {
      return NamatEmptyState(
        illustration: const NamatIcon(
          NamatIcons.package,
          size: 52,
          color: NamatColors.inkSoft,
        ),
        title: emptyTitle,
        body: emptyBody,
        action: FilledButton(
          onPressed: () => context.go('/explore'),
          child: Text(l.useNamatCta),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        NamatSpace.gutter,
        NamatSpace.lg,
        NamatSpace.gutter,
        120,
      ),
      children: revealAll([
        for (final b in bookings)
          Padding(
            padding: const EdgeInsets.only(bottom: NamatSpace.md),
            child: _BookingCard(booking: b),
          ),
      ]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  static const _icons = {
    BookingKind.session: NamatIcons.fitness,
    BookingKind.consultation: NamatIcons.consultation,
    BookingKind.subscription: NamatIcons.package,
    BookingKind.order: NamatIcons.meals,
  };

  static const _accents = {
    BookingKind.session: NamatColors.fitness,
    BookingKind.consultation: NamatColors.nutrition,
    BookingKind.subscription: NamatColors.accent,
    BookingKind.order: NamatColors.food,
  };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final accent = _accents[booking.kind]!;
    final cancelled = booking.state == BookingState.cancelled;

    return NamatCard(
      padding: const EdgeInsets.all(NamatSpace.lg),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NamatIcon(
                _icons[booking.kind]!,
                size: 24,
                // A cancelled booking is greyed rather than removed: it is
                // still the record the member needs to chase a refund.
                color: cancelled ? NamatColors.inkSoft : accent,
              ),
              const SizedBox(width: NamatSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.title,
                      style: text.titleMedium?.copyWith(
                        decoration:
                            cancelled ? TextDecoration.lineThrough : null,
                        color: cancelled ? NamatColors.inkSoft : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(booking.partner, style: text.bodySmall),
                  ],
                ),
              ),
              if (booking.coveredByPackage)
                const NamatIcon(
                  NamatIcons.leaf,
                  size: 15,
                  color: NamatColors.accent,
                  filled: true,
                ),
            ],
          ),
          const SizedBox(height: NamatSpace.md),
          Row(
            children: [
              if (booking.isSubscription && booking.daysRemaining != null)
                _Meta(
                  icon: NamatIcons.journey,
                  label: l.daysRemaining(context.n(booking.daysRemaining!)),
                )
              else if (booking.at != null)
                _Meta(
                  icon: NamatIcons.bell,
                  label: context.dateTime(booking.at!),
                ),
            ],
          ),
          if (booking.state == BookingState.upcoming) ...[
            const SizedBox(height: NamatSpace.md),
            Row(
              children: [
                _Action(label: l.reschedule, onTap: () {}),
                const SizedBox(width: NamatSpace.sm),
                _Action(label: l.cancelBooking, onTap: () {}, danger: true),
              ],
            ),
          ] else if (booking.state == BookingState.completed) ...[
            const SizedBox(height: NamatSpace.md),
            _Action(label: l.rateIt, onTap: () {}),
          ],
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final NamatIcons icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NamatIcon(icon, size: 14, color: NamatColors.inkSoft),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      );
}

class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colour = danger ? NamatColors.danger : NamatColors.deep;

    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: colour.withOpacity(0.35)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: colour),
        ),
      ),
    );
  }
}

/// What the member has actually bought, newest first.
///
/// Kept apart from the three booking tabs because it answers a different
/// question — not "what is coming" but "what did I pay for, and what did I
/// think of it". It is also the only place a rating can be left after the
/// confirmation screen is gone.
class _Orders extends StatelessWidget {
  const _Orders({required this.orders});

  final List<PlacedOrder> orders;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    if (orders.isEmpty) {
      return NamatEmptyState(
        illustration: const NamatIcon(
          NamatIcons.store,
          size: 52,
          color: NamatColors.inkSoft,
        ),
        title: l.noOrdersYet,
        body: l.noOrdersYetBody,
        action: FilledButton(
          onPressed: () => context.go('/explore'),
          child: Text(l.useNamatCta),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        NamatSpace.gutter,
        NamatSpace.lg,
        NamatSpace.gutter,
        120,
      ),
      children: revealAll([
        for (final o in orders)
          Padding(
            padding: const EdgeInsets.only(bottom: NamatSpace.md),
            child: NamatCard(
              padding: const EdgeInsets.all(NamatSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(o.leadTitle, style: text.titleMedium),
                      ),
                      Text(
                        '${context.money(o.total)} ${l.omr}',
                        style: text.labelMedium,
                      ),
                    ],
                  ),
                  if (o.extraCount > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      l.andMore(context.n(o.extraCount)),
                      style: text.labelSmall,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Latin, isolated: the reference is transcribed, not
                      // read as a quantity.
                      Text(
                        ltrIsolate(o.reference),
                        style: text.labelSmall,
                      ),
                      const SizedBox(width: 10),
                      Text(context.dateTime(o.placedAt), style: text.labelSmall),
                    ],
                  ),
                  const SizedBox(height: NamatSpace.md),
                  if (o.isRated)
                    Row(
                      children: [
                        Text(l.yourRating, style: text.labelSmall),
                        const SizedBox(width: 8),
                        for (var i = 1; i <= 5; i++)
                          Icon(
                            i <= o.rating! ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 16,
                            color: i <= o.rating!
                                ? NamatColors.gold
                                : NamatColors.line,
                          ),
                      ],
                    )
                  else
                    OutlinedButton(
                      onPressed: () => context.go('/rate/${o.reference}'),
                      child: Text(l.rateThisOrder),
                    ),
                ],
              ),
            ),
          ),
      ]),
    );
  }
}
