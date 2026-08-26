import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/home_page.dart' show NamatAvatar;
import '../domain/duel.dart';

/// Finding someone to compete with.
///
/// Results carry a name, a handle and three public numbers. Nothing else about
/// an account is exposed here — not a phone number, not a location, not
/// anything health-related. Someone who has closed the door shows without a
/// challenge button rather than being hidden, so a search for a friend does
/// not silently return nothing.
class FindOpponentPage extends StatefulWidget {
  const FindOpponentPage({super.key});

  @override
  State<FindOpponentPage> createState() => _FindOpponentPageState();
}

class _FindOpponentPageState extends State<FindOpponentPage> {
  final _search = TextEditingController();

  static const _people = [
    Opponent(name: 'أحمد', username: 'ahmedfit', level: 8, wins: 14, streak: 6),
    Opponent(name: 'مريم', username: 'maryam', level: 5, wins: 6, streak: 3),
    Opponent(name: 'خالد', username: 'khalid', level: 11, wins: 22, streak: 12),
    Opponent(
      name: 'سالم',
      username: 'salim',
      level: 3,
      wins: 1,
      streak: 0,
      acceptsChallenges: false,
    ),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final q = _search.text.trim().toLowerCase();

    final results = q.isEmpty
        ? _people
        : _people
            .where((p) =>
                p.name.toLowerCase().contains(q) ||
                p.username.toLowerCase().contains(q.replaceAll('@', '')))
            .toList();

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/challenges'),
            icon: const Icon(Icons.arrow_forward),
          ),
          title: Text(l.pickOpponent),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            0,
            NamatSpace.gutter,
            120,
          ),
          children: [
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l.searchUser,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(14),
                  child: NamatIcon(
                    NamatIcons.search,
                    size: 20,
                    color: NamatColors.inkSoft,
                  ),
                ),
              ),
            ),
            const SizedBox(height: NamatSpace.xl),
            if (results.isEmpty)
              NamatEmptyState(
                illustration: const NamatIcon(
                  NamatIcons.profile,
                  size: 52,
                  color: NamatColors.inkSoft,
                ),
                title: l.noUserFound,
              )
            else
              ...revealAll([
                for (final p in results)
                  Padding(
                    padding: const EdgeInsets.only(bottom: NamatSpace.md),
                    child: _PersonCard(person: p),
                  ),
              ]),
          ],
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.person});

  final Opponent person;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return NamatCard(
      padding: const EdgeInsets.all(NamatSpace.lg),
      child: Row(
        children: [
          NamatAvatar(name: person.name, size: 52),
          const SizedBox(width: NamatSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name, style: text.titleMedium),
                Text(handle(person.username), style: text.bodySmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Chip(
                      icon: NamatIcons.reward,
                      label: l.namatLevel(context.n(person.level)),
                      color: NamatColors.accent,
                    ),
                    const SizedBox(width: 8),
                    if (person.streak > 0)
                      _Chip(
                        icon: NamatIcons.leaf,
                        label: context.n(person.streak),
                        color: NamatColors.fitness,
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Someone not accepting challenges keeps their row; only the action
          // goes. Hiding the person entirely would look like a broken search.
          if (person.acceptsChallenges)
            Pressable(
              onTap: () => context.go('/challenges/new/${person.username}'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: NamatColors.deep,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  l.challenge,
                  style: text.labelMedium?.copyWith(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final NamatIcons icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NamatIcon(icon, size: 13, color: color, filled: true),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}
