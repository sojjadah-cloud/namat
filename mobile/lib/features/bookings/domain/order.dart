import 'booking.dart';

/// A placed order, and the choices made while placing it.
///
/// Kept separate from [Booking]: a booking is one thing the member is owed, an
/// order is one act of paying. Buying a week of meals and a class in a single
/// checkout produces one order and two bookings, and collapsing the two would
/// make the receipt unable to explain itself.

/// How the member receives it.
enum Fulfilment {
  /// Brought to an address.
  delivery,

  /// Collected from the partner.
  pickup,

  /// The member goes there — a class, a gym, a clinic room.
  atPartner,

  /// A call. Nothing moves.
  online,
}

/// How it is paid for.
///
/// `allowance` is not a payment method in the banking sense; it is here
/// because from the member's side it answers the same question, and hiding it
/// among the totals is how people lose track of what a package is worth.
enum PaymentMethod { card, applePay, cash, allowance }

class PlacedOrder {
  const PlacedOrder({
    required this.reference,
    required this.items,
    required this.placedAt,
    required this.method,
    required this.fulfilment,
    required this.paid,
    required this.covered,
    this.slot,
    this.address,
    this.rating,
  });

  /// Short, transcribable, and Latin in both languages — it gets read aloud to
  /// a driver or typed into a keypad. See `ltrIsolate` in core/l10n.
  final String reference;

  final List<CartItem> items;
  final DateTime placedAt;
  final PaymentMethod method;
  final Fulfilment fulfilment;

  /// What was actually charged, and what the package absorbed. Stored rather
  /// than recomputed: prices change, and a receipt that silently updates when
  /// a partner raises a price is not a receipt.
  final double paid;
  final double covered;

  /// When it happens, for anything that occupies a time.
  final DateTime? slot;

  final String? address;

  /// The member's rating, once left. Null means not yet rated — distinct from
  /// a zero, which nobody can give.
  final int? rating;

  PlacedOrder withRating(int stars) => PlacedOrder(
        reference: reference,
        items: items,
        placedAt: placedAt,
        method: method,
        fulfilment: fulfilment,
        paid: paid,
        covered: covered,
        slot: slot,
        address: address,
        rating: stars,
      );

  bool get isRated => rating != null;

  /// The order's headline, for a list: the first line, plus a count of the
  /// rest. Naming every item makes a three-item order unreadable at a glance.
  String get leadTitle => items.isEmpty ? '' : items.first.title;

  int get extraCount => items.isEmpty ? 0 : items.length - 1;

  double get total => paid + covered;
}
