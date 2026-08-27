import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/store.dart';

/// What the member tells us while setting up.
///
/// Held in one place and written once at the end rather than saved per screen,
/// so abandoning setup halfway leaves no half-built account behind.
///
/// Everything except the goal is optional. Personalisation that refuses to
/// start until it knows your age is a form, and people leave forms.
enum Goal { lose, active, muscle, start, maintain }

enum ActivityLevel { low, moderate, active, very }

enum Interest { meals, fitness, consult, store, challenges }

class ProfileDraft {
  const ProfileDraft({
    this.phone = '',
    this.name = '',
    this.goal,
    this.activity,
    this.city,
    this.interests = const {},
  });

  final String phone;
  final String name;
  final Goal? goal;
  final ActivityLevel? activity;
  final String? city;
  final Set<Interest> interests;

  ProfileDraft copyWith({
    String? phone,
    String? name,
    Goal? goal,
    ActivityLevel? activity,
    String? city,
    Set<Interest>? interests,
  }) =>
      ProfileDraft(
        phone: phone ?? this.phone,
        name: name ?? this.name,
        goal: goal ?? this.goal,
        activity: activity ?? this.activity,
        city: city ?? this.city,
        interests: interests ?? this.interests,
      );

  /// The one answer the home screen genuinely needs to arrange itself.
  bool get canFinish => goal != null;
}

class ProfileDraftNotifier extends StateNotifier<ProfileDraft>
    with Persisted<ProfileDraft> {
  ProfileDraftNotifier([this.store]) : super(const ProfileDraft()) {
    restore();
  }

  @override
  final NamatStore? store;

  @override
  String get storageKey => StorageKey.draft;

  @override
  Object encode(ProfileDraft value) => {
        // The number is deliberately absent. It is personal data, this store
        // is plain localStorage on the web, and the draft needs it only for
        // the few seconds between typing it and confirming the code — so
        // writing it down buys nothing and leaves it on the device forever.
        'name': value.name,
        'goal': value.goal?.name,
        'activity': value.activity?.name,
        'city': value.city,
        'interests': [for (final i in value.interests) i.name],
      };

  @override
  ProfileDraft decode(Object raw) {
    final map = raw as Map<String, dynamic>;
    return ProfileDraft(
      name: map['name'] as String? ?? '',
      goal: Goal.values.where((g) => g.name == map['goal']).firstOrNull,
      activity: ActivityLevel.values
          .where((a) => a.name == map['activity'])
          .firstOrNull,
      city: map['city'] as String?,
      interests: {
        for (final i in (map['interests'] as List? ?? const []))
          Interest.values.firstWhere((v) => v.name == i),
      },
    );
  }

  void setPhone(String v) => state = state.copyWith(phone: v);
  void setName(String v) => state = state.copyWith(name: v);
  void setGoal(Goal v) => state = state.copyWith(goal: v);
  void setActivity(ActivityLevel v) => state = state.copyWith(activity: v);
  void setCity(String v) => state = state.copyWith(city: v);

  void toggleInterest(Interest v) {
    final next = {...state.interests};
    next.contains(v) ? next.remove(v) : next.add(v);
    state = state.copyWith(interests: next);
  }
}

final profileDraftProvider =
    StateNotifierProvider<ProfileDraftNotifier, ProfileDraft>(
  (ref) => ProfileDraftNotifier(ref.watch(storeProvider)),
);

/// Normalise to E.164 so "9123 4567" and "+968 91234567" are one account.
///
/// The leading trunk zero is dropped: it is how the number is written locally
/// but not part of the international form, and keeping it would make
/// "091234567" and "91234567" two accounts for one handset.
String normalisePhone(String input, {String country = '968'}) {
  var digits = input.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.isEmpty) return input.trim();

  // Already international.
  if (input.trim().startsWith('+')) return '+$digits';

  // 00 is how the Gulf writes the international prefix, and people use it
  // constantly. Without this the leading zeros were stripped as though they
  // were a trunk code and the country code was then added a second time, so
  // 00968 9123 4567 became +968 96891234567 — a number belonging to nobody,
  // and a second account for someone who already had one.
  if (digits.startsWith('00')) digits = digits.substring(2);

  // A local trunk zero.
  digits = digits.replaceFirst(RegExp(r'^0+'), '');

  // Whatever is left either carries the country code or does not.
  return digits.startsWith(country) ? '+$digits' : '+$country$digits';
}

/// Omani mobiles are eight digits after the country code. Anything shorter is
/// a typo rather than a number worth sending a message to.
bool isValidPhone(String input) =>
    RegExp(r'^\+\d{10,15}$').hasMatch(normalisePhone(input));
