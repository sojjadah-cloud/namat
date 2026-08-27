import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/domain/session.dart';
import '../../auth/domain/profile_draft.dart';
import '../../bookings/domain/cart_notifier.dart';
import '../../bookings/domain/order.dart';
import '../../catalogue/domain/catalogue.dart';
import '../../use/domain/field.dart';

/// What Home puts in front of a member, and why.
///
/// Kept out of the widget so the reasoning is testable and so the ordering
/// rules are written once. Home is the screen that decides whether NAMAT feels
/// like a directory or like a journey, and the difference is entirely in what
/// it chooses to show first.

/// The one thing worth doing next.
///
/// Deliberately singular. A list of six suggestions is a menu, and a menu at
/// the top of Home is the same failure as a grid of categories: it hands the
/// decision back to the member instead of making it for them.
enum NextStepKind {
  /// Something booked, coming up.
  upcoming,

  /// An order finished and not yet rated.
  rate,

  /// A cart left behind.
  cart,

  /// Nothing pending — suggest something matched to the goal.
  suggestion,

  /// No goal, no history, nothing to go on.
  none,
}

class NextStep {
  const NextStep(this.kind, {this.order, this.at, this.offering, this.partner});

  final NextStepKind kind;
  final PlacedOrder? order;
  final DateTime? at;
  final Offering? offering;
  final Partner? partner;
}

/// Which fields a goal points at, in the order they matter for that goal.
///
/// A member trying to lose weight is served meals first and a gym second; a
/// member building muscle the other way round. Not a filter — everything stays
/// reachable — but the order of a recommendation list is the recommendation.
const _goalFields = <Goal, List<NamatField>>{
  Goal.lose: [NamatField.meals, NamatField.consult, NamatField.fitness],
  Goal.active: [NamatField.fitness, NamatField.meals, NamatField.stores],
  Goal.muscle: [NamatField.fitness, NamatField.meals, NamatField.stores],
  Goal.start: [NamatField.consult, NamatField.meals, NamatField.fitness],
  Goal.maintain: [NamatField.meals, NamatField.fitness, NamatField.stores],
};

/// The next thing the member should do, chosen by urgency rather than by
/// recency: a booking that is about to happen beats a rating that can wait,
/// and both beat a suggestion.
final nextStepProvider = Provider<NextStep>((ref) {
  final orders = ref.watch(ordersProvider);
  final now = DateTime.now();

  final soonest = orders
      .where((o) => o.slot != null && o.slot!.isAfter(now))
      .toList()
    ..sort((a, b) => a.slot!.compareTo(b.slot!));
  if (soonest.isNotEmpty) {
    return NextStep(
      NextStepKind.upcoming,
      order: soonest.first,
      at: soonest.first.slot,
    );
  }

  final unrated = ref.watch(unratedOrderProvider);
  if (unrated != null) return NextStep(NextStepKind.rate, order: unrated);

  if (ref.watch(cartProvider).isNotEmpty) {
    return const NextStep(NextStepKind.cart);
  }

  final suggestion = ref.watch(suggestionProvider);
  if (suggestion != null) {
    return NextStep(
      NextStepKind.suggestion,
      offering: suggestion.$2,
      partner: suggestion.$1,
    );
  }

  return const NextStep(NextStepKind.none);
});

/// One service matched to the member's goal, in their city, that they can
/// actually buy today.
final suggestionProvider = Provider<(Partner, Offering)?>((ref) {
  final recommended = ref.watch(recommendedProvider);
  return recommended.isEmpty ? null : recommended.first;
});

/// Services worth putting in front of this member, best first.
///
/// Ranked by how well the field matches their goal, then by whether it is
/// covered by their package, then by distance. Anything unbuyable is dropped
/// rather than ranked last: a recommendation the member cannot act on is a
/// worse outcome than a shorter list.
final recommendedProvider = Provider<List<(Partner, Offering)>>((ref) {
  final draft = ref.watch(profileDraftProvider);
  final city = ref.watch(sessionProvider).city;
  final order = _goalFields[draft.goal] ?? NamatField.values;

  final rows = <(Partner, Offering, int)>[];
  for (final p in Catalogue.byCity(city)) {
    final rank = order.indexOf(p.field);
    if (rank < 0) continue;
    for (final o in p.offerings) {
      if (!o.canBuy) continue;
      rows.add((p, o, rank));
    }
  }

  rows.sort((a, b) {
    final byGoal = a.$3.compareTo(b.$3);
    if (byGoal != 0) return byGoal;
    // A covered service costs the member nothing today, which is the strongest
    // reason to try something they have not tried.
    final aCovered = a.$2.coveredByPackage && a.$1.inPackage;
    final bCovered = b.$2.coveredByPackage && b.$1.inPackage;
    if (aCovered != bCovered) return aCovered ? -1 : 1;
    return a.$1.distanceKm.compareTo(b.$1.distanceKm);
  });

  return [for (final r in rows) (r.$1, r.$2)];
});

/// Partners in the member's city, nearest first.
final nearbyProvider = Provider<List<Partner>>((ref) {
  final city = ref.watch(sessionProvider).city;
  return Catalogue.byCity(city)
    ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
});

/// How far through the week's goals the member is.
///
/// Placeholder arithmetic over placed orders until habits and bookings are
/// tracked properly. It is deliberately derived from something real rather
/// than hardcoded, so it reads zero for a new member instead of showing a
/// stranger a 72% they did not earn.
final weekProgressProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  final thisWeek = ref
      .watch(ordersProvider)
      .where((o) => o.placedAt.isAfter(weekAgo))
      .length;
  // Five is the working target: roughly one engagement per weekday.
  return (thisWeek / 5).clamp(0.0, 1.0);
});
