import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the member has chosen about how NAMAT behaves.
///
/// Every one of these defaults to the more private or the quieter option where
/// the choice is not obvious, and the offers channel defaults off. A wellness
/// product that opts people into marketing by default has already decided what
/// it thinks of them.

enum NotificationChannel { bookings, journey, challenges, offers }

class Preferences {
  const Preferences({
    this.locale,
    this.channels = const {
      // The two that are about something the member asked for.
      NotificationChannel.bookings: true,
      NotificationChannel.journey: true,
      NotificationChannel.challenges: true,
      // Marketing, off until asked for.
      NotificationChannel.offers: false,
    },
    this.useLocation = false,
    this.personalise = true,
    this.challengeVisible = true,
  });

  /// Null means follow the device. Arabic is the designed layout, so a device
  /// set to anything else still gets a real English build rather than a
  /// machine translation of the Arabic.
  final Locale? locale;

  final Map<NotificationChannel, bool> channels;

  /// Off until granted. The app works without it — a member picks their city
  /// by hand — so asking on first launch would be asking for something not yet
  /// needed.
  final bool useLocation;

  final bool personalise;

  /// Whether other members can find this one by username to challenge them.
  final bool challengeVisible;

  bool isOn(NotificationChannel c) => channels[c] ?? false;

  Preferences copyWith({
    Locale? locale,
    bool clearLocale = false,
    Map<NotificationChannel, bool>? channels,
    bool? useLocation,
    bool? personalise,
    bool? challengeVisible,
  }) =>
      Preferences(
        locale: clearLocale ? null : (locale ?? this.locale),
        channels: channels ?? this.channels,
        useLocation: useLocation ?? this.useLocation,
        personalise: personalise ?? this.personalise,
        challengeVisible: challengeVisible ?? this.challengeVisible,
      );
}

class PreferencesNotifier extends StateNotifier<Preferences> {
  PreferencesNotifier() : super(const Preferences());

  void setLocale(Locale? locale) => state = locale == null
      ? state.copyWith(clearLocale: true)
      : state.copyWith(locale: locale);

  void setChannel(NotificationChannel c, bool on) => state = state.copyWith(
        channels: {...state.channels, c: on},
      );

  void setLocation(bool on) => state = state.copyWith(useLocation: on);

  void setPersonalise(bool on) => state = state.copyWith(personalise: on);

  void setChallengeVisible(bool on) =>
      state = state.copyWith(challengeVisible: on);
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, Preferences>(
  (ref) => PreferencesNotifier(),
);
