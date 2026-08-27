import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namat/core/routing/router.dart';
import 'package:namat/features/membership/domain/membership.dart';
import 'package:namat/main.dart';

/// The packages screen, on a real phone.
///
/// The card used to be pinned to the pager's height, which meant the only
/// scrollable thing on the screen was the benefits list in its middle. On a
/// short screen the price and the subscribe button were squeezed against the
/// bottom edge with no way to reach them — the screen looked finished at
/// desktop size and was unusable at 360×640, which is most Android phones.

/// A small Android phone: the size that breaks first.
const _phone = Size(360, 640);

Future<ProviderContainer> _pumpPackages(WidgetTester tester) async {
  tester.view.physicalSize = _phone * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(routerProvider).go('/journey/packages');
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const NamatApp()),
  );
  await tester.pump(const Duration(milliseconds: 2600));
  await tester.pump();
  return container;
}

void main() {
  testWidgets('it lays out on a small phone without overflowing',
      (tester) async {
    await _pumpPackages(tester);
    // An overflow here is not cosmetic: the thing pushed off the edge is the
    // button that starts the subscription.
    expect(tester.takeException(), isNull);
  });

  testWidgets('the page scrolls far enough to reach the button',
      (tester) async {
    await _pumpPackages(tester);

    final scroller = find.byType(SingleChildScrollView).first;
    expect(scroller, findsOneWidget);

    // The subscribe button sits below the fold at this height, so getting to
    // it is the whole test.
    final button = find.widgetWithText(FilledButton, 'ابدأ الباقة');
    await tester.ensureVisible(button.first);
    await tester.pumpAndSettle();

    final rect = tester.getRect(button.first);
    expect(rect.bottom, lessThanOrEqualTo(_phone.height));
    expect(rect.top, greaterThanOrEqualTo(0));
  });

  testWidgets('a vertical drag actually moves the card', (tester) async {
    await _pumpPackages(tester);

    final title = find.text('توازن');
    final before = tester.getRect(title.first).top;

    await tester.drag(find.byType(PageView), const Offset(0, -160));
    await tester.pumpAndSettle();

    // Dragging up used to do nothing at all: the outer column had no
    // scrollable of its own and the inner list was already at its end.
    expect(tester.getRect(title.first).top, lessThan(before));
  });

  testWidgets('paging sideways still switches package', (tester) async {
    await _pumpPackages(tester);
    // Opens on the middle card when the member has no package.
    expect(find.text('توازن'), findsWidgets);

    await tester.drag(find.byType(PageView), const Offset(-360, 0));
    await tester.pumpAndSettle();

    // Which neighbour depends on direction — a PageView reverses in RTL, and
    // this build is Arabic — so the assertion is that the pager moved at all,
    // which is what adding a vertical scroller could have broken.
    expect(
      find.text('نشِط').evaluate().isNotEmpty ||
          find.text('متكامل').evaluate().isNotEmpty,
      isTrue,
    );
  });

  testWidgets('choosing a package starts it, and the card says so',
      (tester) async {
    final container = await _pumpPackages(tester);
    expect(container.read(membershipProvider), isNull);

    final button = find.widgetWithText(FilledButton, 'ابدأ الباقة');
    await tester.ensureVisible(button.first);
    await tester.pumpAndSettle();
    await tester.tap(button.first);
    await tester.pumpAndSettle();

    expect(container.read(membershipProvider), isNotNull);
    // The same card now reads as the current one rather than as an offer.
    expect(find.text('باقتك الحالية'), findsWidgets);
  });

  testWidgets('a subscribed member is offered pause and cancel',
      (tester) async {
    final container = await _pumpPackages(tester);
    container.read(membershipProvider.notifier).start('balance');
    await tester.pumpAndSettle();

    // Both exits, equally weighted. Cancelling is never made harder than
    // pausing.
    expect(find.text('أوقف مؤقتاً'), findsOneWidget);
    expect(find.text('إلغاء الاشتراك'), findsOneWidget);
  });
}
