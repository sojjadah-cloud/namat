import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namat/core/routing/router.dart';
import 'package:namat/features/bookings/domain/cart_notifier.dart';
import 'package:namat/features/bookings/domain/order.dart';
import 'package:namat/features/bookings/presentation/cart_page.dart';
import 'package:namat/features/bookings/presentation/checkout_page.dart';
import 'package:namat/features/bookings/presentation/order_done_page.dart';
import 'package:namat/features/catalogue/domain/catalogue.dart';
import 'package:namat/features/partners/presentation/partner_page.dart';
import 'package:namat/features/reviews/presentation/rate_page.dart';
import 'package:namat/main.dart';

/// The whole journey: choose, order, pay, rate.
///
/// Walked as one test rather than four, because the failures worth catching
/// live between the steps — a cart that empties on the way to checkout, a
/// reference the confirmation screen cannot find, a rating that lands on no
/// order. Each step alone passes while the journey is broken.

Future<ProviderContainer> _pumpAt(
  WidgetTester tester,
  String location,
) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(routerProvider).go(location);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const NamatApp()),
  );
  await tester.pump(const Duration(milliseconds: 2600));
  await tester.pump();
  return container;
}

void main() {
  testWidgets('choosing, ordering, paying and rating', (tester) async {
    // A larger surface: the checkout screen is long, and a 600px test window
    // pushes its controls off-screen where a tap cannot reach them.
    tester.view.physicalSize = const Size(1200, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final container = await _pumpAt(tester, '/use/meals/partner/healthy-lab');
    expect(find.byType(PartnerPage), findsOneWidget);

    // --- choose -----------------------------------------------------------
    // Through the sheet rather than by calling the notifier, so the tap path
    // the member actually uses is the one under test.
    await tester.tap(find.text('سلطة تونا عالية البروتين'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // A full second: the sheet's route holds an IgnorePointer until its
    // transition finishes, so a tap sent too early lands on nothing.
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.widgetWithText(FilledButton, 'أضف إلى السلة'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(container.read(cartProvider).length, 1);
    expect(container.read(cartCountProvider), 1);

    // Past the snackbar. A floating snackbar outlives the screen that raised
    // it and sits over the next screen's bottom action — which is a real
    // overlap, not a test artefact, so it is waited out rather than hidden.
    await tester.pump(const Duration(seconds: 5));

    // --- the cart ---------------------------------------------------------
    container.read(routerProvider).go('/cart');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CartPage), findsOneWidget);

    // Covered by the package, so there is nothing left to pay.
    expect(container.read(cartTotalsProvider).payable, 0);

    // --- checkout ---------------------------------------------------------
    container.read(routerProvider).go('/cart/checkout');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CheckoutPage), findsOneWidget);

    // A dish can be delivered or collected, and no payment question is asked
    // because the allowance covers it.
    expect(find.text('توصيل'), findsOneWidget);
    expect(find.text('استلام من المتجر'), findsOneWidget);
    expect(find.text('بطاقة'), findsNothing);

    await tester.tap(find.text('استلام من المتجر'));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.widgetWithText(FilledButton, 'أكّد الطلب'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));

    // --- the order exists -------------------------------------------------
    final orders = container.read(ordersProvider);
    expect(orders.length, 1);
    final order = orders.single;
    expect(order.fulfilment, Fulfilment.pickup);
    expect(order.paid, 0);
    expect(order.covered, 2.5);
    expect(order.isRated, isFalse);

    // The cart is emptied by placing the order, not left to be re-submitted.
    expect(container.read(cartProvider), isEmpty);

    expect(find.byType(OrderDonePage), findsOneWidget);
    expect(find.textContaining(order.reference), findsOneWidget);

    // --- rate -------------------------------------------------------------
    container.read(routerProvider).go('/rate/${order.reference}');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(RatePage), findsOneWidget);

    // Nothing can be submitted before a star is chosen.
    final submit = find.widgetWithText(FilledButton, 'أرسل التقييم');
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);

    await tester.tap(find.byIcon(Icons.star_border_rounded).at(3));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);

    await tester.tap(submit);
    await tester.pump(const Duration(milliseconds: 600));

    final rated = container.read(ordersProvider).single;
    expect(rated.rating, 4);
    expect(rated.isRated, isTrue);

    // And the prompt to rate it is gone, rather than asking again.
    expect(container.read(unratedOrderProvider), isNull);

    // Let the thank-you screen's entry animation finish. Tearing the tree
    // down mid-timer fails the test on an invariant rather than on anything
    // the journey got wrong.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('a consultation is asked for a time, not an address',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final container = await _pumpAt(tester, '/cart');
    container
        .read(cartProvider.notifier)
        .add(Catalogue.offeringById('nc-plan')!);

    container.read(routerProvider).go('/cart/checkout');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Nothing physical is moving, so delivery is not offered at all.
    expect(find.text('توصيل'), findsNothing);
    expect(find.text('عن بُعد'), findsOneWidget);
    expect(find.text('اختر الوقت'), findsOneWidget);

    // This one is not covered by any package, so it does ask how to pay.
    expect(find.text('بطاقة'), findsOneWidget);
  });

  testWidgets('an unknown partner is an error, not another partner',
      (tester) async {
    await _pumpAt(tester, '/use/meals/partner/no-such-place');
    // The old page fell back to a fixed slug, so a bad link quietly showed a
    // different business's menu and prices.
    expect(find.text('ما قدرنا نحمّل البيانات'), findsOneWidget);
  });
}
