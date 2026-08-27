import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/booking.dart';

/// Everything NAMAT owes the member, in one place.
///
/// Three tabs rather than one list, because the questions differ: "what is
/// happening next", "what am I still paying for", and "what did I do". A
/// single chronological list answers the first well and the other two badly.
class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  /// Stand-in until the API exists.
  static final _all = <Booking>[
    Booking(
      id: '1',
      kind: BookingKind.session,
      title: 'حصة ريفورمر',
      partner: 'ريفورم بيلاتس مسقط',
      state: BookingState.upcoming,
      at: DateTime.now().add(const Duration(hours: 5)),
      coveredByPackage: true,
    ),
    Booking(
      id: '2',
      kind: BookingKind.consultation,
      title: 'استشارة تغذية',
      partner: 'عيادة دانة للتغذية',
      state: BookingState.upcoming,
      at: DateTime.now().add(const Duration(days: 3)),
    ),
    const Booking(
      id: '3',
      kind: BookingKind.subscription,
      title: 'خطة وجبات أسبوعية',
      partner: 'Nourish Kitchen',
      state: BookingState.active,
      daysRemaining: 18,
      coveredByPackage: true,
    ),
    Booking(
      id: '4',
      kind: BookingKind.session,
      title: 'حصة لياقة',
      partner: 'نادي أطلس للياقة',
      state: BookingState.completed,
      at: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Booking(
      id: '5',
      kind: BookingKind.order,
      title: 'وجبة غداء متوازنة',
      partner: 'مطعم المعمل الصحي',
      state: BookingState.cancelled,
      at: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    final upcoming = _all
        .where((b) => !b.isSubscription && b.state == BookingState.upcoming)
        .toList();
    final subs = _all.where((b) => b.isSubscription).toList();
    final past = _all.where((b) => b.isPast).toList();

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_forward),
          ),
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
          onPressed: () => context.go('/use'),
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
