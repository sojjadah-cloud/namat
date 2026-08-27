import 'package:flutter_test/flutter_test.dart';
import 'package:namat/features/bookings/domain/booking.dart';

/// Cart arithmetic.
///
/// The one part of this app where a defect takes money from someone, so the
/// awkward cases are pinned rather than assumed: a package covering more than
/// the cart is worth, a cart that is entirely covered, and quantities.

CartItem _item({
  String id = 'x',
  double price = 10,
  int quantity = 1,
  bool covered = false,
}) =>
    CartItem(
      id: id,
      kind: BookingKind.order,
      title: 'x',
      partner: 'y',
      price: price,
      quantity: quantity,
      coveredByPackage: covered,
    );

void main() {
  group('a line', () {
    test('multiplies price by quantity', () {
      expect(_item(price: 3.5, quantity: 2).lineTotal, 7);
    });

    test('a covered line keeps its real price but adds nothing', () {
      final line = _item(price: 3.5, quantity: 2, covered: true);
      // Both matter: the price is what the card displays, the payable is what
      // the member is charged.
      expect(line.lineTotal, 7);
      expect(line.payable, 0);
    });
  });

  group('totals', () {
    test('an empty cart is empty and costs nothing', () {
      const totals = CartTotals([]);
      expect(totals.isEmpty, isTrue);
      expect(totals.subtotal, 0);
      expect(totals.payable, 0);
    });

    test('subtotal counts every line, covered included', () {
      final totals = CartTotals([
        _item(price: 3.5, quantity: 2, covered: true),
        _item(id: 'b', price: 15),
      ]);
      // 7 + 15. The covered line is still part of what the order is worth.
      expect(totals.subtotal, 22);
    });

    test('covered is what the package absorbs', () {
      final totals = CartTotals([
        _item(price: 3.5, quantity: 2, covered: true),
        _item(id: 'b', price: 15),
      ]);
      expect(totals.covered, 7);
      expect(totals.payable, 15);
    });

    test('a fully covered cart is free, not negative', () {
      final totals = CartTotals([
        _item(price: 8, covered: true),
        _item(id: 'b', price: 12, covered: true),
      ]);
      expect(totals.subtotal, 20);
      expect(totals.covered, 20);
      expect(totals.payable, 0);
    });

    test('payable never goes below zero', () {
      // An allowance worth more than the basket does not become credit.
      final totals = CartTotals([_item(price: 5, covered: true)]);
      expect(totals.payable, greaterThanOrEqualTo(0));
    });

    test('subtotal minus covered always equals payable', () {
      final totals = CartTotals([
        _item(price: 3.5, quantity: 3, covered: true),
        _item(id: 'b', price: 15),
        _item(id: 'c', price: 22.5, quantity: 2),
      ]);
      expect(totals.payable, closeTo(totals.subtotal - totals.covered, 0.001));
    });
  });

  group('bookings', () {
    test('a cancelled booking counts as past', () {
      const b = Booking(
        id: '1',
        kind: BookingKind.session,
        title: 'x',
        partner: 'y',
        state: BookingState.cancelled,
      );
      // It stays in history: hiding it makes a refund impossible to find.
      expect(b.isPast, isTrue);
    });

    test('an active subscription is neither upcoming nor past', () {
      const b = Booking(
        id: '1',
        kind: BookingKind.subscription,
        title: 'x',
        partner: 'y',
        state: BookingState.active,
        daysRemaining: 18,
      );
      expect(b.isSubscription, isTrue);
      expect(b.isPast, isFalse);
    });
  });
}
