import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/l10n/numbers.dart';
import '../../home/presentation/home_page.dart' show NamatAvatar;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    // A row with nowhere to go is worse than no row: it teaches people the
    // app is broken. Only the destinations that exist are linked.
    final rows = <(NamatIcons, String, String?)>[
      (NamatIcons.package, l.myBookings, '/home/bookings'),
      (NamatIcons.store, l.myOrders, '/cart'),
      (NamatIcons.reward, l.myPackages, '/journey/packages'),
      (NamatIcons.leaf, l.savedPlaces, null),
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
                const NamatAvatar(name: 'سارة', size: 64),
                const SizedBox(width: NamatSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('سارة', style: text.titleLarge),
                      Text(handle('sara'), style: text.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        l.namatLevel(context.n(8)),
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
