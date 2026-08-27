import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/city.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../account/domain/session.dart';
import '../domain/preferences.dart';

/// Settings, and the four screens under it.
///
/// Written as one file because they are one idea: every switch here is the
/// member telling NAMAT to do less of something, and splitting four short
/// screens across four files would make the shared shell drift apart.
///
/// Nothing here is a dead end. The rows that could not go anywhere used to
/// simply not respond, which teaches people the app is broken; where a
/// destination genuinely does not exist yet, the screen says so in plain
/// language rather than swallowing the tap.

/// A titled page with the standard back affordance.
class _SettingsScaffold extends StatelessWidget {
  const _SettingsScaffold({
    required this.title,
    required this.children,
    this.fallback = '/profile',
  });

  final String title;
  final List<Widget> children;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: NamatBack(fallback: fallback),
          title: Text(title),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.lg,
            NamatSpace.gutter,
            120,
          ),
          children: revealAll(children),
        ),
      ),
    );
  }
}

/// A switch with the reason underneath it.
///
/// The explanation is not decoration. A member deciding whether to share their
/// location is deciding against a benefit they cannot see, and a bare toggle
/// makes that decision for them by default.
class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.value,
    required this.onChanged,
    this.note,
  });

  final String label;
  final String? note;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: NamatSpace.md),
      child: NamatCard(
        padding: const EdgeInsets.symmetric(
          horizontal: NamatSpace.lg,
          vertical: NamatSpace.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: text.bodyMedium),
                  if (note != null) ...[
                    const SizedBox(height: 2),
                    Text(note!, style: text.labelSmall),
                  ],
                ],
              ),
            ),
            const SizedBox(width: NamatSpace.sm),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.danger = false,
  });

  final NamatIcons icon;
  final String label;
  final VoidCallback? onTap;
  final String? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colour = danger ? NamatColors.danger : NamatColors.ink;

    return Padding(
      padding: const EdgeInsets.only(bottom: NamatSpace.sm),
      child: NamatCard(
        padding: const EdgeInsets.all(NamatSpace.lg),
        onTap: onTap,
        child: Row(
          children: [
            NamatIcon(
              icon,
              size: 20,
              color: danger ? NamatColors.danger : NamatColors.inkSoft,
            ),
            const SizedBox(width: NamatSpace.md),
            Expanded(
              child: Text(
                label,
                style: text.bodyMedium?.copyWith(color: colour),
              ),
            ),
            if (trailing != null)
              Text(trailing!, style: text.labelSmall)
            else if (onTap != null)
              const NamatChevron(),
          ],
        ),
      ),
    );
  }
}

/// Told rather than swallowed.
void _notConnected(BuildContext context) {
  final l = L.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l.notConnectedYet),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ---------------------------------------------------------------- settings

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final session = ref.watch(sessionProvider);

    return _SettingsScaffold(
      title: l.settingsTitle,
      children: [
        Text(l.account, style: text.labelMedium),
        const SizedBox(height: NamatSpace.sm),
        _Row(
          icon: NamatIcons.location,
          label: l.addressesTitle,
          onTap: () => context.go('/profile/settings/addresses'),
        ),
        _Row(
          icon: NamatIcons.location,
          label: l.cityTitle,
          trailing: session.city.label(l),
          onTap: () => context.go('/profile/settings/city'),
        ),
        const SizedBox(height: NamatSpace.xl),
        Text(l.preferences, style: text.labelMedium),
        const SizedBox(height: NamatSpace.sm),
        _Row(
          icon: NamatIcons.bell,
          label: l.notificationPrefs,
          onTap: () => context.go('/profile/settings/notifications'),
        ),
        _Row(
          icon: NamatIcons.use,
          label: l.languageTitle,
          onTap: () => context.go('/profile/settings/language'),
        ),
        _Row(
          icon: NamatIcons.search,
          label: l.privacyTitle,
          onTap: () => context.go('/profile/settings/privacy'),
        ),
        _Row(
          icon: NamatIcons.partner,
          label: l.supportTitle,
          onTap: () => context.go('/profile/settings/support'),
        ),
        const SizedBox(height: NamatSpace.xl),
        if (session.isMember)
          _Row(
            icon: NamatIcons.profile,
            label: l.signOut,
            danger: true,
            onTap: () {
              ref.read(sessionProvider.notifier).signOut();
              context.go('/welcome');
            },
          ),
      ],
    );
  }
}

// ------------------------------------------------------------ notifications

class NotificationPrefsPage extends ConsumerWidget {
  const NotificationPrefsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);

    String label(NotificationChannel c) => switch (c) {
          NotificationChannel.bookings => l.notifyBookings,
          NotificationChannel.journey => l.notifyJourney,
          NotificationChannel.challenges => l.notifyChallenges,
          NotificationChannel.offers => l.notifyOffers,
        };

    return _SettingsScaffold(
      title: l.notificationPrefs,
      fallback: '/profile/settings',
      children: [
        for (final c in NotificationChannel.values)
          _Toggle(
            label: label(c),
            // Only the marketing channel needs explaining, because it is the
            // only one the member did not ask for by using the app.
            note: c == NotificationChannel.offers ? l.notifyOffersNote : null,
            value: prefs.isOn(c),
            onChanged: (v) => notifier.setChannel(c, v),
          ),
        const SizedBox(height: NamatSpace.md),
        Text(l.notConnectedYet, style: text.labelSmall),
      ],
    );
  }
}

// ---------------------------------------------------------------- language

class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final current = ref.watch(preferencesProvider).locale;
    final notifier = ref.read(preferencesProvider.notifier);

    Widget option(String label, Locale? locale) {
      final selected = current?.languageCode == locale?.languageCode;
      return Padding(
        padding: const EdgeInsets.only(bottom: NamatSpace.sm),
        child: NamatCard(
          padding: const EdgeInsets.all(NamatSpace.lg),
          color: selected ? NamatColors.greenSoft : NamatColors.surface,
          onTap: () => notifier.setLocale(locale),
          child: Row(
            children: [
              Expanded(child: Text(label, style: text.bodyMedium)),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: NamatColors.deep,
                ),
            ],
          ),
        ),
      );
    }

    return _SettingsScaffold(
      title: l.languageTitle,
      fallback: '/profile/settings',
      children: [
        // Arabic first, because it is the designed layout rather than a
        // translation of the English one.
        option(l.languageArabic, const Locale('ar')),
        option(l.languageEnglish, const Locale('en')),
        const SizedBox(height: NamatSpace.md),
        Text(l.languageNote, style: text.labelSmall),
      ],
    );
  }
}

// ------------------------------------------------------------------ privacy

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);

    return _SettingsScaffold(
      title: l.privacyTitle,
      fallback: '/profile/settings',
      children: [
        _Toggle(
          label: l.privacyLocation,
          note: l.privacyLocationNote,
          value: prefs.useLocation,
          onChanged: notifier.setLocation,
        ),
        _Toggle(
          label: l.privacyPersonalisation,
          note: l.privacyPersonalisationNote,
          value: prefs.personalise,
          onChanged: notifier.setPersonalise,
        ),
        _Toggle(
          label: l.privacyChallengeVisibility,
          note: l.privacyChallengeNote,
          value: prefs.challengeVisible,
          onChanged: notifier.setChallengeVisible,
        ),
        const SizedBox(height: NamatSpace.xl),
        Text(l.privacyData, style: text.labelMedium),
        const SizedBox(height: 2),
        Text(l.privacyDataNote, style: text.labelSmall),
        const SizedBox(height: NamatSpace.md),
        _Row(
          icon: NamatIcons.package,
          label: l.downloadData,
          onTap: () => _notConnected(context),
        ),
        // Present and reachable, not buried. A product that hides the delete
        // button is telling members what it thinks it can get away with.
        _Row(
          icon: NamatIcons.profile,
          label: l.deleteAccount,
          danger: true,
          onTap: () => showDialog<void>(
            context: context,
            builder: (dialog) => AlertDialog(
              title: Text(l.deleteAccount),
              content: Text(l.deleteAccountBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialog).pop(),
                  child: Text(l.cancelKeep),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialog).pop();
                    _notConnected(context);
                  },
                  child: Text(
                    l.deleteAccount,
                    style: const TextStyle(color: NamatColors.danger),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ support

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return _SettingsScaffold(
      title: l.supportTitle,
      fallback: '/profile/settings',
      children: [
        // Categories first, channel second. "What is wrong" routes a member to
        // someone who can help; "how do you want to contact us" makes them
        // guess which queue they belong in.
        Text(l.supportTitle, style: text.labelMedium),
        const SizedBox(height: NamatSpace.sm),
        for (final (icon, label) in [
          (NamatIcons.store, l.supportOrder),
          (NamatIcons.package, l.supportBooking),
          (NamatIcons.reward, l.supportPayment),
          (NamatIcons.profile, l.supportAccount),
          (NamatIcons.partner, l.supportOther),
        ])
          _Row(
            icon: icon,
            label: label,
            onTap: () => _notConnected(context),
          ),
        const SizedBox(height: NamatSpace.xl),
        _Row(
          icon: NamatIcons.search,
          label: l.supportFaq,
          onTap: () => _notConnected(context),
        ),
        _Row(
          icon: NamatIcons.partner,
          label: l.supportWhatsapp,
          onTap: () => _notConnected(context),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------------- city

class CityPage extends ConsumerWidget {
  const CityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final current = ref.watch(sessionProvider).city;

    return _SettingsScaffold(
      title: l.cityTitle,
      fallback: '/profile/settings',
      children: [
        for (final city in NamatCity.values)
          Padding(
            padding: const EdgeInsets.only(bottom: NamatSpace.sm),
            child: NamatCard(
              padding: const EdgeInsets.all(NamatSpace.lg),
              color: city == current
                  ? NamatColors.greenSoft
                  : NamatColors.surface,
              onTap: () =>
                  ref.read(sessionProvider.notifier).setCity(city),
              child: Row(
                children: [
                  Expanded(child: Text(city.label(l), style: text.bodyMedium)),
                  if (city == current)
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: NamatColors.deep,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
