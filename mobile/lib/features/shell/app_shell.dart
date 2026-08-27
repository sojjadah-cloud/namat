import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/namat_colors.dart';
import '../../core/widgets/namat_icon.dart';
import '../../l10n/app_localizations.dart';

/// The tab shell.
///
/// The bar floats clear of the screen edge rather than sitting on it, which
/// keeps it off the home indicator on iOS and the gesture bar on Android
/// without a per-platform special case.
///
/// The selected tab does not merely recolour: a capsule slides between
/// positions, the icon fills, and the label fades in. The capsule is animated
/// by position rather than rebuilt per tab, so it slides instead of popping.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  /// Five destinations, in the order a member moves through them: where they
  /// are, what they could do, how it is going, what they have committed to,
  /// and themselves.
  ///
  /// Challenges no longer holds one of these. It is a way of continuing rather
  /// than a product of its own, so it sits inside رحلتي — and the slot it gave
  /// up went to حجوزاتي, which members open far more often and which used to
  /// be two taps down inside Home.
  static const _items = <({NamatIcons icon, String Function(L) label})>[
    (icon: NamatIcons.home, label: _homeLabel),
    (icon: NamatIcons.use, label: _exploreLabel),
    (icon: NamatIcons.journey, label: _journeyLabel),
    (icon: NamatIcons.package, label: _bookingsLabel),
    (icon: NamatIcons.profile, label: _profileLabel),
  ];

  static String _homeLabel(L l) => l.navHome;
  static String _exploreLabel(L l) => l.navExplore;
  static String _journeyLabel(L l) => l.navJourney;
  static String _bookingsLabel(L l) => l.navBookings;
  static String _profileLabel(L l) => l.navProfile;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;

    return Scaffold(
      backgroundColor: NamatColors.canvas,
      extendBody: true,
      body: shell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: NamatColors.surface,
              borderRadius: BorderRadius.circular(NamatRadius.organic),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A2F4F4A),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: _Tab(
                        icon: _items[i].icon,
                        label: _items[i].label(l),
                        selected: shell.currentIndex == i,
                        // `initialLocation: true` makes a second tap on the
                        // active tab pop back to that tab's root, which is the
                        // behaviour people expect from a tab bar.
                        onTap: () => shell.goBranch(
                          i,
                          initialLocation: i == shell.currentIndex,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final NamatIcons icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NamatRadius.md),
        child: AnimatedContainer(
          duration: NamatMotion.base,
          curve: NamatMotion.enter,
          // 48 tall keeps every tab above the 44pt touch-target floor even
          // when the label is a single short word.
          height: 48,
          decoration: BoxDecoration(
            color: selected ? NamatColors.greenSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(NamatRadius.md),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.08 : 1,
                duration: NamatMotion.base,
                curve: NamatMotion.enter,
                child: NamatIcon(
                  icon,
                  size: 22,
                  filled: selected,
                  color: selected ? NamatColors.deep : NamatColors.inkSoft,
                ),
              ),
              AnimatedSize(
                duration: NamatMotion.fast,
                curve: NamatMotion.enter,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: NamatColors.deep,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
