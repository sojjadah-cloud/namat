import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:namat/core/l10n/arabic.dart';
import 'package:namat/features/bookings/domain/cart_notifier.dart';
import 'package:namat/features/catalogue/domain/catalogue.dart';
import 'package:namat/features/use/domain/field.dart';

/// The catalogue, the cart, and the folding that makes search work.
///
/// These are the parts that fail quietly: a duplicated cart line reads as a
/// double charge, a partner with no offerings shows a page with nothing to
/// buy, and search that does not fold looks like an empty catalogue rather
/// than like a bug.
void main() {
  group('the catalogue', () {
    test('every field has something in it', () {
      // The point of the exercise: a member picking any of the four worlds
      // must land on something. An empty field reads as a broken app.
      for (final f in NamatField.values) {
        expect(
          Catalogue.byField(f),
          isNotEmpty,
          reason: 'field ${f.name} has no partners',
        );
      }
    });

    test('every partner sells something', () {
      for (final p in Catalogue.all) {
        expect(p.offerings, isNotEmpty, reason: p.slug);
      }
    });

    test('slugs are unique', () {
      final slugs = Catalogue.all.map((p) => p.slug).toList();
      expect(slugs.toSet().length, slugs.length);
    });

    test('offering ids are unique across the whole catalogue', () {
      // They key cart lines, so a collision would merge two different items
      // into one and charge for the wrong thing.
      final ids = [
        for (final p in Catalogue.all) ...p.offerings.map((o) => o.id),
      ];
      expect(ids.toSet().length, ids.length);
    });

    test('partnerOf finds the seller of any offering', () {
      for (final p in Catalogue.all) {
        for (final o in p.offerings) {
          expect(Catalogue.partnerOf(o.id)?.slug, p.slug);
        }
      }
    });

    test('an unknown slug resolves to nothing, not to some other partner', () {
      // The old page fell back to a fixed partner, so a bad link silently
      // showed the wrong business.
      expect(Catalogue.bySlug('does-not-exist'), isNull);
    });

    test('fromPrice is the cheapest thing on the list', () {
      final p = Catalogue.bySlug('healthy-lab')!;
      expect(p.fromPrice, 2.5);
    });

    test('nothing is priced at zero', () {
      for (final p in Catalogue.all) {
        for (final o in p.offerings) {
          expect(o.price, greaterThan(0), reason: o.id);
        }
      }
    });

    test('an allowance only applies where the partner is in a package', () {
      // Otherwise a member sees "free from your package" against a business
      // their package does not cover.
      for (final p in Catalogue.all) {
        if (p.inPackage) continue;
        for (final o in p.offerings) {
          expect(
            o.coveredByPackage,
            isFalse,
            reason: '${o.id} claims cover from a partner outside any package',
          );
        }
      }
    });
  });

  group('what checkout has to ask', () {
    test('sessions and consultations need a time', () {
      expect(OfferingKind.session.needsSlot, isTrue);
      expect(OfferingKind.consultation.needsSlot, isTrue);
    });

    test('a pass does not, because the time is chosen later', () {
      expect(OfferingKind.pass.needsSlot, isFalse);
    });

    test('only physical things need delivering', () {
      expect(OfferingKind.dish.needsFulfilment, isTrue);
      expect(OfferingKind.product.needsFulfilment, isTrue);
      expect(OfferingKind.consultation.needsFulfilment, isFalse);
      expect(OfferingKind.session.needsFulfilment, isFalse);
    });
  });

  group('the cart', () {
    Offering offering(String id) => Catalogue.offeringById(id)!;

    test('adding the same thing twice raises the quantity', () {
      // Two identical lines read to a member as a double charge.
      final cart = CartNotifier()
        ..add(offering('hl-tuna-salad'))
        ..add(offering('hl-tuna-salad'));

      expect(cart.state.length, 1);
      expect(cart.state.single.quantity, 2);
    });

    test('different things are separate lines', () {
      final cart = CartNotifier()
        ..add(offering('hl-tuna-salad'))
        ..add(offering('nm-yoga'));
      expect(cart.state.length, 2);
    });

    test('a line carries the partner that sells it', () {
      final cart = CartNotifier()..add(offering('tol-whey'));
      expect(cart.state.single.partner, 'Tree of Life');
    });

    test('setting a quantity to zero removes the line', () {
      final cart = CartNotifier()..add(offering('hl-tuna-salad'));
      cart.setQuantity('hl-tuna-salad', 0);
      expect(cart.state, isEmpty);
    });

    test('a negative quantity also removes rather than going below zero', () {
      final cart = CartNotifier()..add(offering('hl-tuna-salad'));
      cart.setQuantity('hl-tuna-salad', -3);
      expect(cart.state, isEmpty);
    });

    test('an item outside any package is never marked as covered', () {
      final cart = CartNotifier()..add(offering('hk-beef'));
      expect(cart.state.single.coveredByPackage, isFalse);
    });

    test('an item inside a package is covered', () {
      final cart = CartNotifier()..add(offering('hl-tuna-salad'));
      expect(cart.state.single.coveredByPackage, isTrue);
    });

    test('clearing empties it', () {
      final cart = CartNotifier()
        ..add(offering('hl-tuna-salad'))
        ..add(offering('nm-yoga'));
      cart.clear();
      expect(cart.state, isEmpty);
    });
  });

  group('order references', () {
    test('carry no character a person can misread', () {
      // O/0 and I/1 are where reading a reference aloud goes wrong.
      final r = makeReference(Random(7));
      expect(r.startsWith('NM-'), isTrue);
      for (final ch in r.substring(3).split('')) {
        expect('OI01'.contains(ch), isFalse, reason: 'ambiguous $ch in $r');
      }
    });

    test('are pinned by their seed, so a test can rely on one', () {
      expect(makeReference(Random(7)), makeReference(Random(7)));
    });

    test('differ between orders', () {
      final seen = {for (var i = 0; i < 200; i++) makeReference()};
      // Not a uniqueness guarantee — 32^5 is finite — but a collision rate
      // this low would still catch a generator that had stopped varying.
      expect(seen.length, greaterThan(190));
    });
  });

  group('arabic folding', () {
    test('a bare alef finds every hamza form', () {
      expect(matchesArabic('أطلس', 'اطلس'), isTrue);
      expect(matchesArabic('إبراهيم', 'ابراهيم'), isTrue);
      expect(matchesArabic('آسيا', 'اسيا'), isTrue);
    });

    test('hamza carriers fold to the letter beneath', () {
      // م-س-ؤ-و-ل folds to مسوول, so both spellings meet there.
      expect(matchesArabic('مسؤول', 'مسوول'), isTrue);
    });

    test('ta marbuta and ha meet', () {
      expect(matchesArabic('وجبة', 'وجبه'), isTrue);
    });

    test('alef maqsura and ya meet', () {
      expect(matchesArabic('مصطفى', 'مصطفي'), isTrue);
    });

    test('diacritics are ignored', () {
      expect(matchesArabic('يُوَصَّل', 'يوصل'), isTrue);
    });

    test('the definite article does not block a match', () {
      // Substring, not prefix — most of an Arabic catalogue starts with "ال".
      expect(matchesArabic('الطاولة الخضراء', 'طاولة'), isTrue);
    });

    test('an empty query matches everything', () {
      expect(matchesArabic('أي شيء', ''), isTrue);
    });

    test('unrelated words still do not match', () {
      expect(matchesArabic('مطعم المعمل الصحي', 'بيلاتس'), isFalse);
    });

    test('latin names fold case-insensitively', () {
      expect(matchesArabic('Nourish Kitchen', 'nourish'), isTrue);
    });
  });

  group('search over the catalogue', () {
    /// The same match the field page performs.
    bool hits(Partner p, String q) => matchesArabic(
          [
            p.name,
            p.nameEn,
            p.area,
            p.areaEn,
            ...p.tags,
            ...p.tagsEn,
            for (final o in p.offerings) ...[o.name, o.nameEn],
          ].join(' '),
          q,
        );

    test('a dish name finds the kitchen selling it', () {
      // Nobody searches for a partner by name; they search for what they want.
      final found =
          Catalogue.byField(NamatField.meals).where((p) => hits(p, 'كينوا'));
      expect(found.map((p) => p.slug), contains('healthy-lab'));
    });

    test('a tag typed without its hamza still finds the partner', () {
      final found =
          Catalogue.byField(NamatField.meals).where((p) => hits(p, 'بروتين'));
      expect(found, isNotEmpty);
    });

    test('an area finds what is in it', () {
      final found =
          Catalogue.byField(NamatField.meals).where((p) => hits(p, 'الخوير'));
      expect(found.map((p) => p.slug), containsAll(['hilda-keto', 'macro-boost']));
    });
  });
}
