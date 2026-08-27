import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/store.dart';

/// Which numbers already have an account on this device.
///
/// A real registry lives on a server and knows about every device. This one
/// knows only about this one, which is a genuine limitation — but it is enough
/// to stop the case that actually confuses people: signing up again with the
/// number you already used, and being walked through the questions a second
/// time to arrive at an account you already had.
///
/// Numbers are normalised to E.164 before anything else happens. Two spellings
/// of one number becoming two accounts is the support problem this whole flow
/// exists to avoid, and it would defeat the check as surely as not having one.
///
/// What is written down is a SHA-256 digest, never the number. The registry
/// only ever has to answer "have I seen this one", and a digest answers that
/// exactly — so there is no reason for a list of the member's phone numbers to
/// sit in plain localStorage, where any script on the origin can read it.
///
/// This is not encryption and is not claimed to be. An eight-digit Omani
/// mobile is a small enough space to enumerate, so a determined reader with
/// access to the device could still recover a number. It removes casual
/// exposure, which is the threat that actually applies to a key-value store on
/// a shared browser; the real answer is a server holding this instead, and
/// that server does not exist yet.
class AccountsNotifier extends StateNotifier<Set<String>>
    with Persisted<Set<String>> {
  AccountsNotifier([this.store]) : super(const {}) {
    restore();
  }

  @override
  final NamatStore? store;

  @override
  String get storageKey => StorageKey.accounts;

  @override
  Object encode(Set<String> value) => value.toList();

  @override
  Set<String> decode(Object raw) => {for (final p in raw as List) p as String};

  /// The digest of a normalised number.
  static String fingerprint(String e164) =>
      sha256.convert(utf8.encode(e164)).toString();

  bool isRegistered(String e164) =>
      e164.isNotEmpty && state.contains(fingerprint(e164));

  void register(String e164) {
    if (e164.isEmpty) return;
    state = {...state, fingerprint(e164)};
  }

  /// Deliberately not cleared on sign-out.
  ///
  /// Signing out means "this is not my session any more", not "this number was
  /// never used here" — and a member who signs out and back in should meet the
  /// sign-in path, not be offered a fresh set of setup questions.
  void forget(String e164) => state = {...state}..remove(fingerprint(e164));
}

final accountsProvider =
    StateNotifierProvider<AccountsNotifier, Set<String>>(
  (ref) => AccountsNotifier(ref.watch(storeProvider)),
);
