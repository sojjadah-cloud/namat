import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalogue/domain/catalogue.dart';
import 'booking.dart';
import 'order.dart';

/// The cart and the order history, held in memory.
///
/// In memory because there is no backend yet, and that is a real limitation
/// rather than a detail: closing the app loses the cart. Written against
/// Riverpod so the eventual repository swaps in underneath without any screen
/// changing.

/// Characters a person can transcribe over a phone.
///
/// No O/0 and no I/1: an order reference exists to be read aloud to a driver
/// or repeated to a partner, and those two pairs are where that fails.
const _referenceAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

/// A reference like `NM-4K7Q2`.
///
/// Takes its [Random] so a test can pin the output; production passes none and
/// gets a fresh one.
String makeReference([Random? random]) {
  final r = random ?? Random();
  final body = List.generate(
    5,
    (_) => _referenceAlphabet[r.nextInt(_referenceAlphabet.length)],
  ).join();
  return 'NM-$body';
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(const []);

  /// Adds an offering, or raises the quantity if it is already in the cart.
  ///
  /// Merging rather than appending: two identical lines in a cart is a bug
  /// that members read as the app having double-charged them.
  void add(Offering offering, {int quantity = 1}) {
    final partner = Catalogue.partnerOf(offering.id);
    final existing = state.indexWhere((i) => i.id == offering.id);

    if (existing >= 0) {
      final line = state[existing];
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == existing)
            CartItem(
              id: line.id,
              kind: line.kind,
              title: line.title,
              partner: line.partner,
              price: line.price,
              quantity: line.quantity + quantity,
              coveredByPackage: line.coveredByPackage,
            )
          else
            state[i],
      ];
      return;
    }

    state = [
      ...state,
      CartItem(
        id: offering.id,
        kind: _kindOf(offering.kind),
        title: offering.name,
        partner: partner?.name ?? '',
        price: offering.price,
        quantity: quantity,
        // The allowance only applies where both the partner and the item say
        // so: a package that covers a gym does not cover its café.
        coveredByPackage:
            offering.coveredByPackage && (partner?.inPackage ?? false),
      ),
    ];
  }

  void setQuantity(String id, int quantity) {
    if (quantity <= 0) return remove(id);
    state = [
      for (final i in state)
        if (i.id == id)
          CartItem(
            id: i.id,
            kind: i.kind,
            title: i.title,
            partner: i.partner,
            price: i.price,
            quantity: quantity,
            coveredByPackage: i.coveredByPackage,
          )
        else
          i,
    ];
  }

  void remove(String id) =>
      state = [for (final i in state) if (i.id != id) i];

  void clear() => state = const [];

  int get count => state.fold(0, (sum, i) => sum + i.quantity);

  static BookingKind _kindOf(OfferingKind kind) => switch (kind) {
        OfferingKind.dish => BookingKind.order,
        OfferingKind.product => BookingKind.order,
        OfferingKind.plan => BookingKind.subscription,
        OfferingKind.pass => BookingKind.subscription,
        OfferingKind.session => BookingKind.session,
        OfferingKind.consultation => BookingKind.consultation,
      };
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) => CartNotifier());

/// How many items the tab badge shows. Quantities count, so two of one dish
/// reads as two.
final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, i) => sum + i.quantity);
});

final cartTotalsProvider =
    Provider<CartTotals>((ref) => CartTotals(ref.watch(cartProvider)));

class OrdersNotifier extends StateNotifier<List<PlacedOrder>> {
  OrdersNotifier() : super(const []);

  /// Newest first, because that is the one being asked about.
  void place(PlacedOrder order) => state = [order, ...state];

  void rate(String reference, int stars) => state = [
        for (final o in state)
          if (o.reference == reference) o.withRating(stars) else o,
      ];

  PlacedOrder? byReference(String reference) =>
      state.where((o) => o.reference == reference).firstOrNull;
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<PlacedOrder>>(
  (ref) => OrdersNotifier(),
);

/// The most recent order that has not been rated.
///
/// Drives the prompt on Home: asking about the last order is useful, asking
/// about one from three weeks ago is nagging.
final unratedOrderProvider = Provider<PlacedOrder?>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders.where((o) => !o.isRated).firstOrNull;
});
