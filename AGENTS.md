# NAMAT — نمط

A wellness ecosystem for Oman, built as a Flutter application.

## Where things are

Everything lives in `mobile/`. There is no web app: one existed and was
removed — see below.

```
mobile/lib/
  core/
    theme/      colours, spacing, radii, motion, the Material theme
    widgets/    the icon family, cards, backgrounds, empty states
    routing/    GoRouter, with a tab shell that keeps per-tab stacks
  features/     one folder per feature, each data / domain / presentation
  l10n/         app_ar.arb, app_en.arb, and the generated classes
```

## Conventions that are not obvious

**Arabic is the default, not a translation.** `app_ar.arb` is the template
file; English is generated against it. The Arabic layout is the designed one.
Never hardcode a user-visible string in a widget.

**Typography follows the script.** Arabic sets in `PlexArabic` with a taller
line height (1.45 against 1.25); connected letterforms crowd at the leading
that suits Latin. `NamatTheme.of(locale)` handles this — do not hardcode a
family.

**No photography.** Partner logos belong to partners, and a stock photograph
standing in for a real shopfront is a false claim about that business.
Illustrations are drawn from the icon family; absent avatars use a generated
monogram.

**Icons are painted, not imported.** `NamatIcon` draws each glyph with a
`CustomPainter` on a 24-unit grid, so the family shares one stroke width and
one cap style, and any glyph can animate. Add new ones to the enum and the
switch, not as an asset.

**`withValues` does not exist here.** This is Flutter 3.24.3; the colour API
is `withOpacity`. `withValues` arrived in 3.27.

**`pumpAndSettle` will hang on some screens.** Onboarding and the welcome
screen animate continuously by design, so they never settle. Use `pump` with
an explicit duration there.

## Running it

```bash
cd mobile
flutter pub get
flutter gen-l10n     # after editing any .arb file
flutter run
```

```bash
cd mobile && flutter analyze && flutter test
```

## The backend does not exist yet

Every screen runs on sample data written inline. `dio` and secure storage are
in `pubspec.yaml` but nothing is wired to a server.

A backend *was* built and then removed when the product moved to Flutter. It
is in git history at commit `3d0c103` and contains work that has no Flutter
equivalent and should not be rebuilt from scratch:

- a Postgres schema with six applied migrations, covering providers, services,
  packages and allowances, bookings, challenges, peer duels and points;
- 38 researched Muscat food partners, where unverified capabilities are stored
  as null rather than false, and no rating, price or photograph was invented;
- Arabic search folding — the reason `اطلس` finds `أطلس`, maintained by a
  database trigger so it cannot drift from the data;
- 123 tests over the parts that fail quietly: Oman-time day boundaries, duel
  scoring, goal-based ranking.

Recover any of it with `git show 3d0c103:<path>`.
