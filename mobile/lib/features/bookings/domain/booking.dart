/// What a member has booked.
///
/// Subscriptions sit alongside sessions rather than in a separate concept:
/// from the member's side a meal plan and a gym class are both "something
/// NAMAT owes me", and splitting them into two mental models is how people end
/// up not knowing what they have paid for.
enum BookingKind { session, consultation, subscription, order }

enum BookingState { upcoming, active, completed, cancelled }

class Booking {
  const Booking({
    required this.id,
    required this.kind,
    required this.title,
    required this.partner,
    required this.state,
    this.at,
    this.daysRemaining,
    this.coveredByPackage = false,
  });

  final String id;
  final BookingKind kind;
  final String title;
  final String partner;
  final BookingState state;

  /// When it happens. Null for subscriptions, which run over a period rather
  /// than occurring at a moment.
  final DateTime? at;

  /// Days left on a subscription. Null for everything else.
  final int? daysRemaining;

  /// Spent from an allowance rather than paid for again.
  final bool coveredByPackage;

  bool get isSubscription => kind == BookingKind.subscription;

  /// Past means done or cancelled — a cancelled booking still belongs to the
  /// member's history, and hiding it makes a refund impossible to find.
  bool get isPast =>
      state == BookingState.completed || state == BookingState.cancelled;
}

/// One line in the cart.
///
/// Meals, products and consultations share a cart on purpose: they are one
/// purchase from the member's side, and three separate checkouts for one
/// evening's decisions is the friction NAMAT exists to remove.
class CartItem {
  const CartItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.partner,
    required this.price,
    this.quantity = 1,
    this.coveredByPackage = false,
  });

  final String id;
  final BookingKind kind;
  final String title;
  final String partner;

  /// In OMR. The list price, before any allowance is applied.
  final double price;
  final int quantity;

  /// True when an allowance absorbs it. The line still shows its real price
  /// struck through rather than silently reading zero — a member should be
  /// able to see what the package just saved them.
  final bool coveredByPackage;

  double get lineTotal => price * quantity;

  /// What this line actually adds to the bill.
  double get payable => coveredByPackage ? 0 : lineTotal;
}

/// The arithmetic of a cart, kept out of the widget so it can be tested.
class CartTotals {
  const CartTotals(this.items);

  final List<CartItem> items;

  /// Everything at list price, including covered lines.
  double get subtotal =>
      items.fold(0, (sum, i) => sum + i.lineTotal);

  /// What the package absorbs.
  double get covered =>
      items.where((i) => i.coveredByPackage).fold(0, (sum, i) => sum + i.lineTotal);

  /// What the member is charged. Never negative: an allowance covering more
  /// than the cart is worth does not become credit.
  double get payable => (subtotal - covered).clamp(0, double.infinity);

  bool get isEmpty => items.isEmpty;
}
