import 'package:flutter/material.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';

/// Notifications.
///
/// Grouped by day and coloured by what they are about, so the list can be
/// scanned rather than read. Unread carries a dot and a tinted ground; read
/// entries stay legible rather than greying out, because an old notification
/// is still the record of something that happened.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

typedef _Note = (NamatIcons icon, Color colour, String body, bool unread);

class _NotificationsPageState extends State<NotificationsPage> {
  late List<_Note> _today = [
    (
      NamatIcons.challenge,
      NamatColors.fitness,
      'أحمد قبل تحديك',
      true,
    ),
    (
      NamatIcons.leaf,
      NamatColors.accent,
      'باقي ٥٠٠ خطوة فقط لتتصدر التحدي',
      true,
    ),
  ];

  late List<_Note> _earlier = [
    (
      NamatIcons.package,
      NamatColors.products,
      'باقة توازن تتجدد بعد ١٩ يوم',
      false,
    ),
    (
      NamatIcons.reward,
      NamatColors.gold,
      'حصلت على ١٥٠ نقطة نمط',
      false,
    ),
  ];

  void _markAllRead() {
    setState(() {
      _today = [for (final n in _today) (n.$1, n.$2, n.$3, false)];
      _earlier = [for (final n in _earlier) (n.$1, n.$2, n.$3, false)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final anyUnread =
        _today.any((n) => n.$4) || _earlier.any((n) => n.$4);

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const NamatBack(),
          title: Text(l.notifications),
          actions: [
            if (anyUnread)
              TextButton(
                onPressed: _markAllRead,
                child: Text(l.markAllRead, style: text.labelSmall),
              ),
          ],
        ),
        body: _today.isEmpty && _earlier.isEmpty
            ? NamatEmptyState(
                illustration: const NamatIcon(
                  NamatIcons.bell,
                  size: 52,
                  color: NamatColors.inkSoft,
                ),
                title: l.noNotifications,
                body: l.noNotificationsBody,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  NamatSpace.gutter,
                  0,
                  NamatSpace.gutter,
                  120,
                ),
                children: revealAll([
                  if (_today.isNotEmpty) ...[
                    Text(l.today, style: text.labelSmall),
                    const SizedBox(height: NamatSpace.sm),
                    for (final n in _today) _Row(note: n),
                    const SizedBox(height: NamatSpace.xl),
                  ],
                  if (_earlier.isNotEmpty) ...[
                    Text(l.earlier, style: text.labelSmall),
                    const SizedBox(height: NamatSpace.sm),
                    for (final n in _earlier) _Row(note: n),
                  ],
                ]),
              ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.note});

  final _Note note;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (icon, colour, body, unread) = note;

    return Padding(
      padding: const EdgeInsets.only(bottom: NamatSpace.sm),
      child: NamatCard(
        color: unread ? colour.withOpacity(0.08) : NamatColors.surface,
        elevated: !unread,
        padding: const EdgeInsets.all(NamatSpace.lg),
        onTap: () {},
        child: Row(
          children: [
            NamatIcon(icon, size: 22, color: colour),
            const SizedBox(width: NamatSpace.md),
            Expanded(child: Text(body, style: text.bodyMedium)),
            if (unread)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colour,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
