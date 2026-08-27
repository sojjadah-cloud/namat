import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../account/domain/session.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../challenges/domain/duels_provider.dart';
import '../../challenges/domain/personal_challenges.dart';
import '../../journey/domain/habits.dart';
import '../../rewards/domain/points.dart';
import '../../home/presentation/home_page.dart' show NamatAvatar;

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final name = ref.watch(greetingNameProvider);
    final session = ref.watch(sessionProvider);
    final points = ref.watch(pointsBalanceProvider);
    final streak = ref.watch(streakProvider);
    // Challenges the member actually finished, plus any duel they started.
    // A count that includes challenges they only looked at is not a count of
    // anything.
    final challenges =
        ref.watch(claimedProvider).length + ref.watch(duelsProvider).length;

    // Things the member has, then one door to everything they can change.
    //
    // Privacy, language and support used to sit here as well as inside
    // Settings. Tapping one from this list and pressing back landed on the
    // Settings screen — a page the member had never opened — because the
    // route it deep-linked to carries Settings in its own path. One entry
    // point per destination, and back always retraces the way in.
    final rows = <(NamatIcons, String, String?)>[
      (NamatIcons.package, l.myBookings, '/bookings'),
      (NamatIcons.reward, l.pointsTitle, '/profile/points'),
      (NamatIcons.leaf, l.favoritesTitle, '/profile/favorites'),
      (NamatIcons.challenge, l.challengesTitle, '/journey/challenges'),
      (NamatIcons.package, l.myPackages, '/journey/packages'),
      (NamatIcons.profile, l.settingsTitle, '/profile/settings'),
    ];

    return NamatBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.xl,
            NamatSpace.gutter,
            120,
          ),
          children: [
            Row(
              children: [
                NamatAvatar(name: name, size: 64),
                const SizedBox(width: NamatSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The member's own name, not a fixture. A profile that
                      // greets everyone as the same person is the one screen
                      // where placeholder data is unmissable.
                      Text(
                        name.isEmpty ? l.profileTitle : name,
                        style: text.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      // The city, not a second copy of the numbers that sit
                      // in the card directly below. Two zeros stacked above
                      // three more read as an error rather than as an empty
                      // account.
                      Row(
                        children: [
                          const NamatIcon(
                            NamatIcons.location,
                            size: 13,
                            color: NamatColors.inkSoft,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            session.city.label(l),
                            style: text.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: NamatSpace.xl),
            NamatCard(
              padding: const EdgeInsets.symmetric(vertical: NamatSpace.lg),
              child: Row(
                children: [
                  // All three read zero for a new account, because all three
                  // are read from what the member has done. They used to be
                  // Arabic string literals — ١٬٢٨٠ points, ٢٤ challenges, ١٥
                  // wins — on the one screen where a stranger's numbers are
                  // unmissable.
                  Expanded(
                    child: _Stat(
                      value: context.n(points),
                      labelKey: 'points',
                    ),
                  ),
                  Container(width: 1, height: 34, color: NamatColors.line),
                  Expanded(
                    child: _Stat(
                      value: context.n(challenges),
                      labelKey: 'challenges',
                    ),
                  ),
                  Container(width: 1, height: 34, color: NamatColors.line),
                  // Streak rather than wins: there is no server to settle a
                  // duel, so a win is not a thing the app can know. A streak
                  // is, and it is the number this product is about.
                  Expanded(
                    child: _Stat(
                      value: context.n(streak),
                      labelKey: 'streak',
                    ),
                  ),
                ],
              ),
            ),
            if (session.isGuest) ...[
              const SizedBox(height: NamatSpace.lg),
              NamatCard(
                color: NamatColors.greenSoft,
                elevated: false,
                padding: const EdgeInsets.all(NamatSpace.lg),
                onTap: () => context.go('/login'),
                child: Row(
                  children: [
                    const NamatIcon(
                      NamatIcons.leaf,
                      size: 20,
                      color: NamatColors.accent,
                      filled: true,
                    ),
                    const SizedBox(width: NamatSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.guestProfile, style: text.bodyMedium),
                          const SizedBox(height: 2),
                          Text(l.guestProfileBody, style: text.labelSmall),
                        ],
                      ),
                    ),
                    const NamatChevron(),
                  ],
                ),
              ),
            ],
            const SizedBox(height: NamatSpace.xl),
            for (final (icon, label, route) in rows)
              ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: route != null,
                leading: NamatIcon(icon, size: 22, color: NamatColors.inkSoft),
                title: Text(label, style: text.bodyMedium),
                // Chevron points the way the reader is going, which under RTL
                // is toward the start edge.
                trailing: const Icon(
                  Icons.chevron_right,
                  color: NamatColors.inkSoft,
                ),
                onTap: route == null ? null : () => context.go(route),
              ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.labelKey});

  final String value;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final label = switch (labelKey) {
      'points' => l.namatPoints,
      'challenges' => l.statChallengesDone,
      _ => l.statStreak,
    };

    return Column(
      children: [
        Text(value, style: text.titleLarge),
        const SizedBox(height: 2),
        Text(label, style: text.labelSmall),
      ],
    );
  }
}
