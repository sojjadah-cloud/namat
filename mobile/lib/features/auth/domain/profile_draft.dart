import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class ProfileDraftNotifier extends StateNotifier<ProfileDraft> {
  ProfileDraftNotifier() : super(const ProfileDraft());

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
  (ref) => ProfileDraftNotifier(),
);

/// Normalise to E.164 so "9123 4567" and "+968 91234567" are one account.
///
/// The leading trunk zero is dropped: it is how the number is written locally
/// but not part of the international form, and keeping it would make
/// "091234567" and "91234567" two accounts for one handset.
String normalisePhone(String input, {String country = '968'}) {
  final digits = input.replaceAll(RegExp(r'[^\d]'), '');
  if (input.trim().startsWith('+')) return '+$digits';
  if (digits.startsWith(country)) return '+$digits';
  return '+$country${digits.replaceFirst(RegExp(r'^0+'), '')}';
}

/// Omani mobiles are eight digits after the country code. Anything shorter is
/// a typo rather than a number worth sending a message to.
bool isValidPhone(String input) =>
    RegExp(r'^\+\d{10,15}$').hasMatch(normalisePhone(input));
