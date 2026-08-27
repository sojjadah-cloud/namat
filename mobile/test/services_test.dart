import 'package:flutter_test/flutter_test.dart';
import 'package:namat/features/bookings/domain/cart_notifier.dart';
import 'package:namat/features/catalogue/domain/catalogue.dart';
import 'package:namat/features/use/domain/field.dart';

/// The facts a service carries, and the two that change what the app does:
/// whether there is room, and when it runs.
///
/// The timetable is the one worth pinning. It is computed from a weekday and
/// an hour rather than stored as dates, so a fixed list cannot silently drift
/// into the past — but the arithmetic that makes that work is exactly where an
/// off-by-one hides, and an off-by-one here books somebody a week early.
void main() {
  Offering byId(String id) => Catalogue.offeringById(id)!;

  group('availability', () {
    test('not counting places is not the same as having none', () {
      // A dish nobody counts must never render as sold out.
      const untracked = Availability();
      expect(untracked.spotsLeft, isNull);
      expect(untracked.isFull, isFalse);

      const full = Availability(spotsLeft: 0);
      expect(full.isFull, isTrue);
    });

    test('nearly full is a narrow band, not everything below capacity', () {
      expect(const Availability(spotsLeft: 3).isNearlyFull, isTrue);
      expect(const Availability(spotsLeft: 4).isNearlyFull, isFalse);
      // Zero is full, which is a louder state than nearly full, not this one.
      expect(const Availability(spotsLeft: 0).isNearlyFull, isFalse);
    });

    test('a service with no timetable offers no times', () {
      expect(const Availability().upcoming(DateTime(2026, 8, 27)), isEmpty);
    });
  });

  group('session times', () {
    test('the next occurrence lands on the right weekday', () {
      // Thursday 27 August 2026, 09:00.
      final from = DateTime(2026, 8, 27, 9);
      expect(from.weekday, DateTime.thursday);

      const sundaySix = SessionTime(DateTime.sunday, 18);
      final next = sundaySix.nextAfter(from);
      expect(next.weekday, DateTime.sunday);
      expect(next.hour, 18);
      expect(next.isAfter(from), isTrue);
    });

    test("today's slot counts if it has not passed yet", () {
      final from = DateTime(2026, 8, 27, 9);
      const thursdaySix = SessionTime(DateTime.thursday, 18);
      final next = thursdaySix.nextAfter(from);
      // Same day, nine hours later — not next week.
      expect(next.day, 27);
      expect(next.hour, 18);
    });

    test("today's slot is skipped once it has passed", () {
      final from = DateTime(2026, 8, 27, 19);
      const thursdaySix = SessionTime(DateTime.thursday, 18);
      final next = thursdaySix.nextAfter(from);
      // A week on: offering a time that has already gone is worse than
      // offering none.
      expect(next.difference(from).inDays, greaterThanOrEqualTo(6));
      expect(next.weekday, DateTime.thursday);
    });

    test('a slot exactly now is treated as passed', () {
      final from = DateTime(2026, 8, 27, 18);
      const thursdaySix = SessionTime(DateTime.thursday, 18);
      // Booking the minute it starts is not booking it.
      expect(thursdaySix.nextAfter(from).day, isNot(27));
    });

    test('minutes are carried, not rounded to the hour', () {
      final from = DateTime(2026, 8, 27, 9);
      const t = SessionTime(DateTime.friday, 18, 30);
      expect(t.nextAfter(from).minute, 30);
    });

    test('every generated time is in the future', () {
      final from = DateTime(2026, 8, 27, 13, 45);
      for (final day in [
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
        DateTime.sunday,
      ]) {
        for (final hour in [0, 6, 13, 14, 23]) {
          final next = SessionTime(day, hour).nextAfter(from);
          expect(next.isAfter(from), isTrue, reason: 'day $day hour $hour');
          expect(next.weekday, day, reason: 'day $day hour $hour');
        }
      }
    });

    test('a twice-weekly class fills six slots by repeating weeks', () {
      // Two times a week cannot fill six slots from one week; without the
      // repeat the member sees two and assumes the class is nearly over.
      const availability = Availability(
        times: [
          SessionTime(DateTime.monday, 19),
          SessionTime(DateTime.wednesday, 19),
        ],
      );
      final times = availability.upcoming(DateTime(2026, 8, 27, 9));
      expect(times.length, 6);
      expect(times.toSet().length, 6, reason: 'duplicates: $times');
    });

    test('times come back soonest first', () {
      final times = byId('ns-day').availability!.upcoming(DateTime(2026, 8, 27));
      for (var i = 1; i < times.length; i++) {
        expect(times[i].isAfter(times[i - 1]), isTrue);
      }
    });
  });

  group('opening hours', () {
    const nineToFive = OpeningHours(
      opensAt: 9 * 60,
      closesAt: 17 * 60,
      closedOn: [DateTime.friday],
    );

    test('open inside the window', () {
      expect(nineToFive.isOpenAt(DateTime(2026, 8, 27, 12)), isTrue);
    });

    test('closed before opening and after closing', () {
      expect(nineToFive.isOpenAt(DateTime(2026, 8, 27, 8, 59)), isFalse);
      expect(nineToFive.isOpenAt(DateTime(2026, 8, 27, 17)), isFalse);
    });

    test('opening minute counts, closing minute does not', () {
      // A door that is open at exactly closing time is a door someone arrives
      // at to find locked.
      expect(nineToFive.isOpenAt(DateTime(2026, 8, 27, 9)), isTrue);
      expect(nineToFive.isOpenAt(DateTime(2026, 8, 27, 16, 59)), isTrue);
    });

    test('a closed day is closed at every hour', () {
      // Friday 28 August 2026.
      final friday = DateTime(2026, 8, 28, 12);
      expect(friday.weekday, DateTime.friday);
      expect(nineToFive.isOpenAt(friday), isFalse);
    });

    test('formats as clock time with a padded minute', () {
      expect(OpeningHours.format(6 * 60), '6:00');
      expect(OpeningHours.format(18 * 60 + 30), '18:30');
      expect(OpeningHours.format(9 * 60 + 5), '9:05');
    });
  });

  group('what the catalogue promises', () {
    test('only NAMAT services carry hours, phones and policies', () {
      // A third party has not told us any of these, and inventing them makes
      // promises on their behalf — a wrong closing time sends a member to a
      // locked door.
      for (final p in Catalogue.all) {
        if (p.firstParty) continue;
        expect(p.hours, isNull, reason: p.slug);
        expect(p.phone, isNull, reason: p.slug);
        expect(p.about, isNull, reason: p.slug);
        for (final o in p.offerings) {
          expect(o.cancellation, isNull, reason: o.id);
          expect(o.availability, isNull, reason: o.id);
        }
      }
    });

    test('everything that occupies a time says how long it takes', () {
      for (final p in Catalogue.all) {
        for (final o in p.offerings) {
          if (!o.kind.needsSlot) continue;
          expect(o.minutes, isNotNull, reason: o.id);
          expect(o.minutes, greaterThan(0), reason: o.id);
        }
      }
    });

    test('every NAMAT session states its cancellation policy', () {
      for (final p in Catalogue.all.where((p) => p.firstParty)) {
        for (final o in p.offerings) {
          if (!o.kind.needsSlot && o.kind != OfferingKind.pass) continue;
          expect(o.cancellation, isNotNull, reason: o.id);
        }
      }
    });

    test('a spots figure never exceeds the capacity it came from', () {
      for (final p in Catalogue.all) {
        for (final o in p.offerings) {
          final a = o.availability;
          if (a?.spotsLeft == null || a?.capacity == null) continue;
          expect(a!.spotsLeft, lessThanOrEqualTo(a.capacity!), reason: o.id);
        }
      }
    });

    test('both languages are filled in for every included line', () {
      // One side missing shows an empty list to half the members.
      for (final p in Catalogue.all) {
        for (final o in p.offerings) {
          expect(
            o.includes.length,
            o.includesEn.length,
            reason: '${o.id} has ${o.includes.length} ar and '
                '${o.includesEn.length} en',
          );
        }
      }
    });

    test('every field still has something buyable in it', () {
      for (final f in NamatField.values) {
        final partners = Catalogue.byField(f);
        expect(partners, isNotEmpty, reason: f.name);
        expect(
          partners.any((p) => p.hasAnythingAvailable),
          isTrue,
          reason: '${f.name} is entirely sold out',
        );
      }
    });

    test('the sold-out class really is sold out', () {
      // Kept deliberately in the data: a catalogue where nothing is ever full
      // never exercises the state members meet most.
      final hiit = byId('nm-hiit');
      expect(hiit.isSoldOut, isTrue);
      expect(hiit.canBuy, isFalse);
    });
  });

  group('the cart refuses what cannot be sold', () {
    test('a sold-out class is not added', () {
      final cart = CartNotifier()..add(byId('nm-hiit'));
      // Disabled in the sheet too, but a deep link must not be able to take
      // money for a place that does not exist.
      expect(cart.state, isEmpty);
    });

    test('an available class from the same partner is added', () {
      final cart = CartNotifier()..add(byId('nm-yoga'));
      expect(cart.state.length, 1);
    });

    test('a partner is only fully unavailable when everything is', () {
      // NAMAT Move has one full class and three that are not.
      expect(Catalogue.bySlug('namat-move')!.hasAnythingAvailable, isTrue);
    });
  });
}
