import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Saved things.
///
/// One store for every kind rather than a list per section: a member does not
/// think "my saved gyms" and "my saved dishes" separately, they think "the
/// things I liked". The kind is carried on the entry so one screen can group
/// them without five providers to keep in step.
enum FavouriteKind { partner, offering, bundle }

class Favourite {
  const Favourite(this.kind, this.id);

  final FavouriteKind kind;

  /// A partner slug, an offering id, or a bundle id.
  final String id;

  /// Two favourites are the same when they point at the same thing. Written
  /// out because a Set of these is the whole data structure, and the default
  /// identity would let the same partner be saved twice.
  @override
  bool operator ==(Object other) =>
      other is Favourite && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);
}

class FavouritesNotifier extends StateNotifier<Set<Favourite>> {
  FavouritesNotifier() : super(const {});

  bool contains(FavouriteKind kind, String id) =>
      state.contains(Favourite(kind, id));

  /// Returns what the state became, so a caller can show the right message
  /// without reading the provider again on the next frame.
  bool toggle(FavouriteKind kind, String id) {
    final f = Favourite(kind, id);
    if (state.contains(f)) {
      state = {...state}..remove(f);
      return false;
    }
    state = {...state, f};
    return true;
  }

  void clear() => state = const {};

  Iterable<String> idsOf(FavouriteKind kind) =>
      state.where((f) => f.kind == kind).map((f) => f.id);
}

final favouritesProvider =
    StateNotifierProvider<FavouritesNotifier, Set<Favourite>>(
  (ref) => FavouritesNotifier(),
);

/// Whether one specific thing is saved.
///
/// A family so a heart on a card rebuilds when that thing is saved and not
/// when anything else is.
final isFavouriteProvider =
    Provider.family<bool, Favourite>((ref, favourite) {
  return ref.watch(favouritesProvider).contains(favourite);
});

final favouritesCountProvider =
    Provider<int>((ref) => ref.watch(favouritesProvider).length);
