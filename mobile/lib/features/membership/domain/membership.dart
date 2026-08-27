import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bookings/domain/booking.dart';
import '../../bookings/domain/cart_notifier.dart';
import '../../catalogue/domain/catalogue.dart';

/// A NAMAT package, and what is left of it.
///
/// The counters are the product. A member renews because they can see that
/// eleven of twelve meals were used, not because a brochure told them the
/// package was good value — and a member who cannot see the counters assumes
/// they are being undercounted, which is worse than any price.

/// What a package grants, by kind.
///
/// Keyed on [OfferingKind] rather than on named benefits so the allowance can
/// actually be checked against a cart. A benefit written as free text reads
/// well on a card and cannot be enforced anywhere.
enum Allowance { meals, sessions, consultations }

extension AllowanceRules on Allowance {
  bool covers(OfferingKind kind) => switch (this) {
        Allowance.meals =>
          kind == OfferingKind.dish || kind == OfferingKind.plan,
        Allowance.sessions =>
          kind == OfferingKind.session || kind == OfferingKind.pass,
        Allowance.consultations => kind == OfferingKind.consultation,
      };
}

class NamatPackage {
  const NamatPackage({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.bestFor,
    required this.bestForEn,
    required this.monthlyPrice,
    required this.grants,
    this.benefits = const [],
    this.benefitsEn = const [],
  });

  final String id;
  final String name;
  final String nameEn;
  final String bestFor;
  final String bestForEn;

  /// In OMR.
  final double monthlyPrice;

  /// How many of each kind, per month.
  final Map<Allowance, int> grants;

  final List<String> benefits;
  final List<String> benefitsEn;

  String localisedName(bool arabic) => arabic ? name : nameEn;
  String localisedBestFor(bool arabic) => arabic ? bestFor : bestForEn;
  List<String> localisedBenefits(bool arabic) => arabic ? benefits : benefitsEn;
}

const namatPackages = <NamatPackage>[
  NamatPackage(
    id: 'active',
    name: 'نشِط',
    nameEn: 'Active',
    bestFor: 'لمن يتدرّب ويريد للغذاء أن يواكبه',
    bestForEn: 'For someone training, who wants the food to keep up',
    monthlyPrice: 39,
    grants: {Allowance.sessions: 8, Allowance.meals: 4},
    benefits: [
      'ثماني حصص رياضية شهرياً',
      'أربع وجبات من مطابخ الشركاء',
      'خصم على منتجات المتاجر',
    ],
    benefitsEn: [
      'Eight classes a month',
      'Four meals from partner kitchens',
      'A discount at partner stores',
    ],
  ),
  NamatPackage(
    id: 'balance',
    name: 'توازن',
    nameEn: 'Balance',
    bestFor: 'لمن يبني عادات أفضل، أسبوعاً بعد أسبوع',
    bestForEn: 'For building better habits, a week at a time',
    monthlyPrice: 55,
    grants: {
      Allowance.meals: 12,
      Allowance.sessions: 6,
      Allowance.consultations: 1,
    },
    benefits: [
      'اثنتا عشرة وجبة من مطابخ الشركاء',
      'ست حصص رياضية',
      'استشارة تغذية واحدة',
    ],
    benefitsEn: [
      'Twelve meals from partner kitchens',
      'Six classes',
      'One nutrition consultation',
    ],
  ),
  NamatPackage(
    id: 'complete',
    name: 'متكامل',
    nameEn: 'Complete',
    bestFor: 'لمن يريد المنظومة كاملة، دون حساب',
    bestForEn: 'For the whole ecosystem, without counting',
    monthlyPrice: 89,
    grants: {
      Allowance.meals: 24,
      Allowance.sessions: 12,
      Allowance.consultations: 3,
    },
    benefits: [
      'أربع وعشرون وجبة',
      'اثنتا عشرة حصة رياضية',
      'ثلاث استشارات',
      'أولوية في الحجز',
    ],
    benefitsEn: [
      'Twenty-four meals',
      'Twelve classes',
      'Three consultations',
      'Priority booking',
    ],
  ),
];

/// An active subscription.
class Membership {
  const Membership({
    required this.packageId,
    required this.startedAt,
    this.paused = false,
  });

  final String packageId;
  final DateTime startedAt;

  /// Paused, not cancelled. A member who has to cancel to take a month off
  /// mostly does not come back, so pausing is offered first — and cancelling
  /// is never made harder than pausing, which would be the same trick played
  /// the other way.
  final bool paused;

  NamatPackage? get package =>
      namatPackages.where((p) => p.id == packageId).firstOrNull;

  /// Renews monthly. Approximate by design — the real date comes from the
  /// billing system, and inventing precision here would be inventing a
  /// commitment.
  DateTime get renewsAt {
    final now = DateTime.now();
    var next = DateTime(startedAt.year, startedAt.month, startedAt.day);
    while (!next.isAfter(now)) {
      next = DateTime(next.year, next.month + 1, next.day);
    }
    return next;
  }

  int get daysRemaining => renewsAt.difference(DateTime.now()).inDays;

  Membership copyWith({bool? paused}) => Membership(
        packageId: packageId,
        startedAt: startedAt,
        paused: paused ?? this.paused,
      );
}

class MembershipNotifier extends StateNotifier<Membership?> {
  MembershipNotifier() : super(null);

  void start(String packageId) =>
      state = Membership(packageId: packageId, startedAt: DateTime.now());

  void pause() => state = state?.copyWith(paused: true);

  void resume() => state = state?.copyWith(paused: false);

  /// Cancelling is one call and takes effect. Never a maze — a product that
  /// makes leaving hard is telling its members it does not expect them to
  /// stay for any other reason.
  void cancel() => state = null;
}

final membershipProvider =
    StateNotifierProvider<MembershipNotifier, Membership?>(
  (ref) => MembershipNotifier(),
);

/// How much of each allowance has been spent this cycle.
///
/// Counted from placed orders rather than tracked separately, so the number a
/// member sees is derived from what they actually bought and cannot drift away
/// from their own history.
final allowanceUsedProvider = Provider<Map<Allowance, int>>((ref) {
  final membership = ref.watch(membershipProvider);
  final orders = ref.watch(ordersProvider);
  if (membership == null) return const {};

  final since = membership.renewsAt.subtract(const Duration(days: 30));
  final used = <Allowance, int>{};

  for (final o in orders) {
    if (o.placedAt.isBefore(since)) continue;
    for (final item in o.items) {
      if (!item.coveredByPackage) continue;
      final kind = Catalogue.offeringById(item.id)?.kind;
      if (kind == null) continue;
      for (final a in Allowance.values) {
        if (a.covers(kind)) {
          used[a] = (used[a] ?? 0) + item.quantity;
        }
      }
    }
  }
  return used;
});

/// What is left, per allowance. Never negative.
final allowanceLeftProvider = Provider<Map<Allowance, int>>((ref) {
  final membership = ref.watch(membershipProvider);
  final used = ref.watch(allowanceUsedProvider);
  final grants = membership?.package?.grants ?? const <Allowance, int>{};

  return {
    for (final entry in grants.entries)
      entry.key: (entry.value - (used[entry.key] ?? 0)).clamp(0, entry.value),
  };
});

/// Whether an allowance can still absorb one more of this kind.
///
/// The check the cart needs: a package that has run out of meals for the month
/// must stop marking meals as free, or the member is told something is covered
/// and then charged for it.
bool allowanceCovers(Map<Allowance, int> left, OfferingKind kind) {
  for (final entry in left.entries) {
    if (entry.key.covers(kind) && entry.value > 0) return true;
  }
  return false;
}

/// What a member would have saved this month if they had been subscribed.
///
/// Computed from their own orders rather than from a brochure figure. It is
/// the one argument for a package that a member cannot dismiss as marketing,
/// because it is made entirely of things they chose themselves.
final potentialSavingProvider = Provider<double>((ref) {
  final orders = ref.watch(ordersProvider);
  final monthAgo = DateTime.now().subtract(const Duration(days: 30));
  var total = 0.0;
  for (final o in orders.where((o) => o.placedAt.isAfter(monthAgo))) {
    for (final item in o.items) {
      final kind = Catalogue.offeringById(item.id)?.kind;
      if (kind == null) continue;
      if (Allowance.values.any((a) => a.covers(kind))) {
        total += item.payable;
      }
    }
  }
  return total;
});

/// The kinds a cart line has to match for the current package to cover it.
final cartCoverageProvider = Provider<bool Function(CartItem)>((ref) {
  final left = ref.watch(allowanceLeftProvider);
  return (item) {
    final kind = Catalogue.offeringById(item.id)?.kind;
    if (kind == null) return false;
    return allowanceCovers(left, kind);
  };
});
