import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Saved delivery addresses.
///
/// Free text, on purpose. Most of Oman is addressed by description rather than
/// by street number — "the villa behind the mosque in Falaj Al Qabail" is how
/// a driver is actually directed — and a form with separate street, number and
/// postcode fields would force people to invent data that helps nobody and
/// then fail validation on the truth.
class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.detail,
  });

  final String id;

  /// What the member calls it: home, work, mother's.
  final String label;

  /// How to find it.
  final String detail;
}

class AddressesNotifier extends StateNotifier<List<SavedAddress>> {
  AddressesNotifier() : super(const []);

  void add(String label, String detail) {
    final trimmed = detail.trim();
    if (trimmed.isEmpty) return;
    state = [
      ...state,
      SavedAddress(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        label: label.trim(),
        detail: trimmed,
      ),
    ];
  }

  void remove(String id) => state = [for (final a in state) if (a.id != id) a];
}

final addressesProvider =
    StateNotifierProvider<AddressesNotifier, List<SavedAddress>>(
  (ref) => AddressesNotifier(),
);
