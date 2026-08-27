import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../account/domain/session.dart';
import '../../favorites/domain/favorites.dart';
import '../../rewards/domain/points.dart';
import '../../../core/l10n/numbers.dart';
import '../../home/presentation/home_page.dart' show NamatAvatar;

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final name = ref.watch(greetingNameProvider);
    final points = ref.watch(pointsBalanceProvider);
    final saved = ref.watch(favouritesCountProvider);

    // A row with nowhere to go is worse than no row: it teaches people the
    // app is broken. Only the destinations that exist are linked.
    final rows = <(NamatIcons, String, String?)>[
      (NamatIcons.package, l.myBookings, '/bookings'),
      (NamatIcons.reward, l.pointsTitle, '/profile/points'),
      (NamatIcons.leaf, l.favoritesTitle, '/profile/favorites'),
      (NamatIcons.package, l.myPackages, '/journey/packages'),
      (NamatIcons.challenge, l.challengesTitle, '/journey/challenges'),
      (NamatIcons.profile, l.settings, null),
      (NamatIcons.search, l.privacy, null),
      (NamatIcons.use, l.language, null),
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
                      Text(
                        '${context.n(points)} ${l.pointsTitle} · '
                        '${context.n(saved)} ${l.saved}',
                        style: text.labelSmall?.copyWith(
                          color: NamatColors.accent,
                        ),
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
                  const Expanded(
                    child: _Stat(value: '١٬٢٨٠', labelKey: 'points'),
                  ),
                  Container(width: 1, height: 34, color: NamatColors.line),
                  const Expanded(
                    child: _Stat(value: '٢٤', labelKey: 'challenges'),
                  ),
                  Container(width: 1, height: 34, color: NamatColors.line),
                  const Expanded(child: _Stat(value: '١٥', labelKey: 'wins')),
                ],
              ),
            ),
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
                  Icons.chevron_left,
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
      'challenges' => l.challengesTitle,
      _ => l.challenge,
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
