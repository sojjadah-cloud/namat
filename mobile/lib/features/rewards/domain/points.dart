import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/store.dart';

/// Namat Points.
///
/// A ledger rather than a running total. A member who cannot see why their
/// balance changed does not trust it, and "you have 340 points" answers a
/// question nobody asked — what they want to know is what earned them, and
/// what they are short of.
///
/// Points are earned for finishing things, not for spending. Awarding them by
/// value would make the programme a discount on large orders, which is a
/// different product and a worse one for a service about continuing.

enum PointsReason {
  /// Completing an order or a booking.
  order,

  /// Rating something afterwards.
  review,

  /// Finishing a challenge.
  challenge,

  /// A day added to a streak.
  streak,

  /// First time at a partner.
  newPartner,

  /// Spent on a reward.
  redeemed,
}

/// What each action is worth.
///
/// Balanced against the cheapest reward rather than picked in isolation. The
/// first version paid 20 for an order and 10 for a review against a 250-point
/// reward, which is nine complete order-and-rate cycles before a single button
/// stopped being grey — so in practice every reward was permanently out of
/// reach and the screen looked broken. A member who turns up for two weeks
/// should be able to spend something.
///
/// Still weighted towards continuing rather than spending: a daily habit log
/// is worth half an order, so the person who shows up every day gets there at
/// about the same rate as the person who buys a lot.
const pointsFor = <PointsReason, int>{
  PointsReason.order: 25,
  PointsReason.review: 15,
  PointsReason.challenge: 100,
  PointsReason.streak: 10,
  PointsReason.newPartner: 40,
  PointsReason.redeemed: 0,
};

class PointsEntry {
  const PointsEntry({
    required this.reason,
    required this.amount,
    required this.at,
    this.detail,
  });

  final PointsReason reason;

  /// Signed: negative when redeemed. One list, so the balance is always the
  /// sum of what the member can see.
  final int amount;
  final DateTime at;

  /// What it was for — an order reference, a partner, a challenge.
  final String? detail;
}

class PointsNotifier extends StateNotifier<List<PointsEntry>>
    with Persisted<List<PointsEntry>> {
  PointsNotifier([this.store]) : super(const []) {
    restore();
  }

  @override
  final NamatStore? store;

  @override
  String get storageKey => StorageKey.points;

  @override
  Object encode(List<PointsEntry> value) => [
        for (final e in value)
          {
            'reason': e.reason.name,
            'amount': e.amount,
            'at': e.at.toIso8601String(),
            'detail': e.detail,
          },
      ];

  @override
  List<PointsEntry> decode(Object raw) => [
        for (final e in raw as List)
          PointsEntry(
            reason: PointsReason.values
                .firstWhere((r) => r.name == (e as Map)['reason']),
            amount: (e as Map)['amount'] as int,
            at: DateTime.parse(e['at'] as String),
            detail: e['detail'] as String?,
          ),
      ];

  void award(PointsReason reason, {String? detail, DateTime? at}) {
    final amount = pointsFor[reason] ?? 0;
    if (amount == 0) return;
    state = [
      PointsEntry(
        reason: reason,
        amount: amount,
        at: at ?? DateTime.now(),
        detail: detail,
      ),
      ...state,
    ];
  }

  /// Spends points. Refuses rather than going negative: a balance that can go
  /// below zero is a debt the member never agreed to.
  bool redeem(int amount, {String? detail}) {
    if (amount <= 0 || amount > balanceOf(state)) return false;
    state = [
      PointsEntry(
        reason: PointsReason.redeemed,
        amount: -amount,
        at: DateTime.now(),
        detail: detail,
      ),
      ...state,
    ];
    return true;
  }

  /// Awards once for a given reason and detail, ever.
  ///
  /// The daily streak and the first visit to a partner both have to be
  /// idempotent: a member who logs water twice on Tuesday has not earned
  /// Tuesday twice, and re-ordering from the same kitchen is not a new
  /// partner. Keyed on the detail so the check lives here rather than in
  /// whichever screen happens to call it.
  bool awardOnce(PointsReason reason, {required String detail}) {
    final already = state.any(
      (e) => e.reason == reason && e.detail == detail,
    );
    if (already) return false;
    award(reason, detail: detail);
    return true;
  }

  static int balanceOf(List<PointsEntry> entries) =>
      entries.fold(0, (sum, e) => sum + e.amount);
}

final pointsProvider =
    StateNotifierProvider<PointsNotifier, List<PointsEntry>>(
  (ref) => PointsNotifier(ref.watch(storeProvider)),
);

final pointsBalanceProvider = Provider<int>(
  (ref) => PointsNotifier.balanceOf(ref.watch(pointsProvider)),
);

/// A thing points can be exchanged for.
class Reward {
  const Reward({
    required this.id,
    required this.cost,
    required this.title,
    required this.titleEn,
    required this.detail,
    required this.detailEn,
  });

  final String id;
  final int cost;
  final String title;
  final String titleEn;
  final String detail;
  final String detailEn;

  String localisedTitle(bool arabic) => arabic ? title : titleEn;
  String localisedDetail(bool arabic) => arabic ? detail : detailEn;
}

/// What NAMAT itself can honour.
///
/// Only NAMAT's own services, on purpose. A reward that spends a partner's
/// margin is a commitment that partner has to have agreed to, and none has.
const namatRewards = <Reward>[
  Reward(
    id: 'r-class',
    cost: 120,
    title: 'حصة رياضية مجانية',
    titleEn: 'A free class',
    detail: 'أي حصة في نمط سبورت',
    detailEn: 'Any class at NAMAT Sport',
  ),
  Reward(
    id: 'r-follow-up',
    cost: 220,
    title: 'متابعة تغذية مجانية',
    titleEn: 'A free nutrition follow-up',
    detail: 'جلسة عشرين دقيقة',
    detailEn: 'A twenty-minute session',
  ),
  Reward(
    id: 'r-month',
    cost: 600,
    title: 'شهر في نمط حركة',
    titleEn: 'A month at NAMAT Move',
    detail: 'كل الحصص، ثلاثين يوماً',
    detailEn: 'Every class, thirty days',
  ),
];
