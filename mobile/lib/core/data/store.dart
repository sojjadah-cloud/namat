import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence.
///
/// Everything the member owns lived in memory, which on the web means a page
/// reload wipes it — and pasting a URL into the address bar is a reload. So
/// choosing a package, then opening the app again, showed no package: not a
/// bug in the membership, a bug in it never having been written down.
///
/// `shared_preferences` was already a dependency and had never been used. It
/// maps to `localStorage` on the web and to the platform's own key-value store
/// elsewhere, which is the right home for this kind of state: small, per
/// device, and not worth a database.
///
/// Tokens do not belong here — `flutter_secure_storage` is in the pubspec for
/// those, and nothing writes one yet because there is no server to issue one.

class NamatStore {
  const NamatStore(this._prefs);

  final SharedPreferences _prefs;

  /// Reads and decodes, returning null on anything unreadable.
  ///
  /// A corrupt or outdated value must never stop the app from starting. The
  /// worst outcome of a decode failing is that one list comes back empty; the
  /// worst outcome of it throwing is a member who cannot open the app at all
  /// and has no way to clear it.
  Object? read(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  void write(String key, Object value) {
    // Fire and forget: the write is a cache of state that is already correct
    // in memory, so a failed write costs the next launch, not this one.
    _prefs.setString(key, jsonEncode(value));
  }

  void remove(String key) => _prefs.remove(key);

  /// Everything the member owns, for signing out.
  void clearAll() {
    for (final key in _StorageKeys.all) {
      _prefs.remove(key);
    }
  }
}

abstract final class _StorageKeys {
  static const all = [
    StorageKey.session,
    StorageKey.draft,
    StorageKey.membership,
    StorageKey.points,
    StorageKey.favourites,
    StorageKey.habits,
    StorageKey.claimed,
    StorageKey.orders,
    StorageKey.cart,
    StorageKey.duels,
    StorageKey.addresses,
    // StorageKey.accounts is deliberately absent. Signing out means "this is
    // not my session any more", not "this number was never used here" — and a
    // member signing back in should meet the sign-in path rather than a fresh
    // set of setup questions.
  ];
}

/// The keys, in one place so two features cannot collide on one.
abstract final class StorageKey {
  static const session = 'namat.session';
  static const draft = 'namat.draft';
  static const membership = 'namat.membership';
  static const points = 'namat.points';
  static const favourites = 'namat.favourites';
  static const habits = 'namat.habits';
  static const claimed = 'namat.claimed';
  static const orders = 'namat.orders';
  static const cart = 'namat.cart';
  static const duels = 'namat.duels';
  static const addresses = 'namat.addresses';
  static const accounts = 'namat.accounts';
  static const preferences = 'namat.preferences';
}

/// Null until [main] overrides it, and null in tests.
///
/// Optional rather than required so a test can build a container without
/// standing up a fake store: a notifier with no store simply does not persist,
/// which is exactly the behaviour a unit test wants.
final storeProvider = Provider<NamatStore?>((ref) => null);

/// A notifier that writes itself down whenever it changes.
///
/// The save hangs off the state setter rather than off each mutating method,
/// because the failure mode of the alternative is a new method added later
/// that quietly does not persist — and that fault is invisible until someone
/// reopens the app.
mixin Persisted<T> on StateNotifier<T> {
  NamatStore? get store;
  String get storageKey;

  /// How this notifier's state becomes JSON, and back.
  Object encode(T value);
  T? decode(Object raw);

  @override
  set state(T value) {
    super.state = value;
    store?.write(storageKey, encode(value));
  }

  /// Called from the constructor body, after the initial state is set.
  ///
  /// Assigns through `super.state` rather than `state` so restoring does not
  /// immediately write back what was just read.
  void restore() {
    final raw = store?.read(storageKey);
    if (raw == null) return;
    try {
      final decoded = decode(raw);
      if (decoded != null) super.state = decoded;
    } catch (_) {
      // Outgrown or hand-edited data. Dropped rather than repaired: guessing
      // at what a half-readable record meant is how one bad launch becomes a
      // permanently wrong balance.
      store?.remove(storageKey);
    }
  }
}
