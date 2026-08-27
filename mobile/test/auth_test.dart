import 'package:flutter_test/flutter_test.dart';
import 'package:namat/features/auth/domain/profile_draft.dart';

/// Phone normalisation and the setup draft.
///
/// The normalisation matters more than it looks: two spellings of one number
/// becoming two accounts is a support problem that only shows up after launch,
/// when the same person cannot find their bookings.
void main() {
  group('phone normalisation', () {
    test('a bare local number gets the country code', () {
      expect(normalisePhone('91234567'), '+96891234567');
    });

    test('spaces and punctuation are ignored', () {
      expect(normalisePhone('9123 4567'), '+96891234567');
      expect(normalisePhone('9123-4567'), '+96891234567');
    });

    test('an already-international number is left alone', () {
      expect(normalisePhone('+968 91234567'), '+96891234567');
      expect(normalisePhone('96891234567'), '+96891234567');
    });

    test('a leading trunk zero is dropped', () {
      // Written locally as 091234567; keeping the zero would make it a second
      // account for the same handset.
      expect(normalisePhone('091234567'), '+96891234567');
      expect(normalisePhone('0 9123 4567'), '+96891234567');
    });

    test('every spelling of one number collapses to one string', () {
      const spellings = [
        '91234567',
        '9123 4567',
        '+968 9123 4567',
        '96891234567',
        '091234567',
      ];
      final normalised = spellings.map(normalisePhone).toSet();
      expect(normalised.length, 1, reason: normalised.join(' | '));
    });
  });

  group('validation', () {
    test('accepts an Omani mobile', () {
      expect(isValidPhone('91234567'), isTrue);
    });

    test('rejects something too short to be a number', () {
      expect(isValidPhone('912'), isFalse);
      expect(isValidPhone(''), isFalse);
    });
  });

  group('the setup draft', () {
    test('cannot finish without a goal', () {
      const draft = ProfileDraft();
      // Everything else is optional; the goal is what Home arranges around.
      expect(draft.canFinish, isFalse);
      expect(draft.copyWith(goal: Goal.lose).canFinish, isTrue);
    });

    test('interests toggle both ways', () {
      final n = ProfileDraftNotifier();
      n.toggleInterest(Interest.meals);
      expect(n.state.interests, {Interest.meals});
      n.toggleInterest(Interest.fitness);
      expect(n.state.interests, {Interest.meals, Interest.fitness});
      n.toggleInterest(Interest.meals);
      expect(n.state.interests, {Interest.fitness});
    });

    test('answers survive later edits to other answers', () {
      final n = ProfileDraftNotifier()
        ..setPhone('+96891234567')
        ..setGoal(Goal.muscle)
        ..setCity('مسقط');
      n.setName('سارة');

      expect(n.state.phone, '+96891234567');
      expect(n.state.goal, Goal.muscle);
      expect(n.state.city, 'مسقط');
      expect(n.state.name, 'سارة');
    });
  });
}
