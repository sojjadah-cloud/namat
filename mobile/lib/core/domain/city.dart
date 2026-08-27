/// The cities NAMAT operates in, and the one it launches in.
///
/// Sohar is first. That is a real constraint rather than a default: the
/// researched partner catalogue is Muscat, so a member in Sohar opening the
/// meals field finds NAMAT's own services and nothing else. The app says that
/// plainly and offers to show Muscat, instead of rendering an empty list that
/// reads as a broken app.
///
/// Every city here is one the architecture supports; a city with no partners
/// is a supply problem, not a missing feature.
library;

import '../../l10n/app_localizations.dart';

enum NamatCity {
  sohar,
  muscat,
  salalah,
  nizwa,
  sur,
  barka;

  /// The launch market.
  static const launch = NamatCity.sohar;

  static NamatCity? byName(String name) =>
      NamatCity.values.where((c) => c.name == name).firstOrNull;

  /// The city's name in the reader's language.
  ///
  /// On the enum rather than copied into each screen: the same city appearing
  /// as "صحار" on one page and "Sohar" on another is the kind of drift that
  /// three separate switch statements guarantee.
  String label(L l) => switch (this) {
        NamatCity.sohar => l.citySohar,
        NamatCity.muscat => l.cityMuscat,
        NamatCity.salalah => l.citySalalah,
        NamatCity.nizwa => l.cityNizwa,
        NamatCity.sur => l.citySur,
        NamatCity.barka => l.cityBarka,
      };
}
