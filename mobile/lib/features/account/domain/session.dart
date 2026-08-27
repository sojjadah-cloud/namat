import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/store.dart';

import '../../../core/domain/city.dart';
import '../../auth/domain/profile_draft.dart';

/// Who is using the app, and what they are allowed to do.
///
/// A guest can do almost everything: browse every partner, read every service,
/// search, open a bundle, look at a challenge. What a guest cannot do is
/// anything that creates an obligation — ordering, booking, joining, saving.
/// Blocking the catalogue behind a sign-up is how a marketplace loses the
/// people who have not decided yet; blocking a booking is simply what a
/// booking requires.
enum SessionKind {
  /// Browsing without an account. The default on first launch.
  guest,

  /// Signed in.
  member,
}

/// Actions a guest is stopped at, so the prompt can say which one.
enum GatedAction { order, book, join, favourite, challenge }

class Session {
  const Session({
    this.kind = SessionKind.guest,
    this.name = '',
    this.city = NamatCity.launch,
    this.hasPackage = false,
  });

  final SessionKind kind;
  final String name;

  /// Where the member is. Defaults to the launch market rather than to
  /// nothing, so a guest who has not chosen sees a real city's supply.
  final NamatCity city;

  /// Whether an active NAMAT package is running. Changes what the journey and
  /// the profile show, and whether an allowance can absorb a line.
  final bool hasPackage;

  bool get isGuest => kind == SessionKind.guest;
  bool get isMember => kind == SessionKind.member;

  Session copyWith({
    SessionKind? kind,
    String? name,
    NamatCity? city,
    bool? hasPackage,
  }) =>
      Session(
        kind: kind ?? this.kind,
        name: name ?? this.name,
        city: city ?? this.city,
        hasPackage: hasPackage ?? this.hasPackage,
      );
}

class SessionNotifier extends StateNotifier<Session> with Persisted<Session> {
  SessionNotifier([this.store]) : super(const Session()) {
    restore();
  }

  @override
  final NamatStore? store;

  @override
  String get storageKey => StorageKey.session;

  @override
  Object encode(Session value) => {
        'kind': value.kind.name,
        'name': value.name,
        'city': value.city.name,
        'hasPackage': value.hasPackage,
      };

  @override
  Session? decode(Object raw) {
    final map = raw as Map<String, dynamic>;
    return Session(
      kind: SessionKind.values
              .where((k) => k.name == map['kind'])
              .firstOrNull ??
          SessionKind.guest,
      name: map['name'] as String? ?? '',
      city: NamatCity.byName(map['city'] as String? ?? '') ?? NamatCity.launch,
      hasPackage: map['hasPackage'] as bool? ?? false,
    );
  }

  void signIn({String name = '', NamatCity? city}) => state = state.copyWith(
        kind: SessionKind.member,
        name: name.isEmpty ? state.name : name,
        city: city,
      );

  /// Signing out clears everything the member owns, not just the session.
  /// Leaving their points and their habit log behind for whoever opens the
  /// app next is the opposite of what signing out means.
  void signOut() {
    store?.clearAll();
    state = const Session();
  }

  void setCity(NamatCity city) => state = state.copyWith(city: city);

  void setName(String name) => state = state.copyWith(name: name);

  void setPackage(bool active) => state = state.copyWith(hasPackage: active);
}

final sessionProvider = StateNotifierProvider<SessionNotifier, Session>(
  (ref) => SessionNotifier(ref.watch(storeProvider)),
);

/// The name to greet with, from whichever source has it.
///
/// The setup draft is where a new member types their name, and the session is
/// where it lives afterwards. Reading both means the greeting works during the
/// first session as well as every one after it.
final greetingNameProvider = Provider<String>((ref) {
  final session = ref.watch(sessionProvider);
  if (session.name.isNotEmpty) return session.name;
  return ref.watch(profileDraftProvider).name;
});
