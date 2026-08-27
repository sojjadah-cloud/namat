import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../membership/domain/membership.dart';

/// NAMAT packages, and the one the member is on.
///
/// A member can move between them from here — up, down, or off entirely. A
/// subscription screen that can only be joined is a trap, and members can tell
/// the difference before they subscribe, not after.
///
/// Cancelling is never made harder than pausing. Pausing is offered first
/// because someone taking a month off mostly does not come back if the only
/// door is cancellation — but that is a reason to offer a better option, not
/// to hide the exit.
class PackagesPage extends ConsumerStatefulWidget {
  const PackagesPage({super.key});

  @override
  ConsumerState<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends ConsumerState<PackagesPage> {
  late final PageController _controller;
  int _index = 0;

  /// The look of each package. Kept next to the screen rather than in the
  /// domain: a colour is a presentation decision, and the allowances are not.
  static const _looks = <String, (NamatIcons, Color, Color)>{
    'active': (NamatIcons.fitness, NamatColors.fitness, NamatColors.fitnessSoft),
    'balance': (NamatIcons.leaf, NamatColors.accent, NamatColors.greenSoft),
    'complete': (NamatIcons.reward, NamatColors.products, NamatColors.productsSoft),
  };

  @override
  void initState() {
    super.initState();
    // Opens on the member's own package when they have one, so the screen
    // answers "what am I on" before it answers "what else is there".
    final current = ref.read(membershipProvider)?.packageId;
    _index = current == null
        ? 1
        : namatPackages.indexWhere((p) => p.id == current).clamp(0, 2);
    _controller = PageController(initialPage: _index, viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmCancel() async {
    final l = L.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.cancelConfirm),
        content: Text(l.cancelConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l.cancelKeep),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(
              l.cancelMembership,
              style: const TextStyle(color: NamatColors.danger),
            ),
          ),
        ],
      ),
    );
    // One confirmation, not a survey. Asking why on the way out is a dark
    // pattern wearing a research hat.
    if (ok ?? false) ref.read(membershipProvider.notifier).cancel();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final membership = ref.watch(membershipProvider);

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const NamatBack(fallback: '/journey'),
          title: Text(l.packagesTitle),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NamatSpace.gutter,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l.packagesSub, style: text.bodySmall),
              ),
            ),
            const SizedBox(height: NamatSpace.xl),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: namatPackages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = namatPackages[i];
                  final look = _looks[p.id]!;
                  final current = membership?.packageId == p.id;
                  return AnimatedScale(
                    // The focused card sits slightly forward, so the eye knows
                    // which one it is reading.
                    scale: i == _index ? 1 : 0.94,
                    duration: NamatMotion.base,
                    curve: NamatMotion.enter,
                    child: SingleChildScrollView(
                      // The card is as tall as its own content, and this is
                      // what lets it exceed the screen. Before, it was pinned
                      // to the pager's height and the only scrollable thing
                      // was the benefits list in its middle — so on a phone
                      // the price and the button were squeezed against the
                      // bottom and nothing could be scrolled to reach them.
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, NamatSpace.xl),
                      child: _PackageCard(
                        package: p,
                        icon: look.$1,
                        accent: look.$2,
                        tint: look.$3,
                        arabic: arabic,
                        current: current,
                        hasOther: membership != null && !current,
                        onChoose: () {
                          ref
                              .read(membershipProvider.notifier)
                              .start(p.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(p.localisedName(arabic)),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: NamatSpace.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < namatPackages.length; i++)
                  AnimatedContainer(
                    duration: NamatMotion.base,
                    curve: NamatMotion.enter,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 6,
                    width: i == _index ? 22 : 6,
                    decoration: BoxDecoration(
                      color:
                          i == _index ? NamatColors.deep : NamatColors.line,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
              ],
            ),
            if (membership != null) ...[
              const SizedBox(height: NamatSpace.md),
              // Both exits, equally weighted. Wrap rather than Row: the two
              // labels are 47 pixels too wide together at 360dp, and a Row
              // clips the second one — which is the one that lets a member
              // leave.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NamatSpace.gutter,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: NamatSpace.sm,
                  children: [
                    TextButton(
                      onPressed: () => membership.paused
                          ? ref.read(membershipProvider.notifier).resume()
                          : ref.read(membershipProvider.notifier).pause(),
                      child: Text(
                        membership.paused
                            ? l.resumeMembership
                            : l.pauseMembership,
                      ),
                    ),
                    TextButton(
                      onPressed: _confirmCancel,
                      child: Text(
                        l.cancelMembership,
                        style: const TextStyle(color: NamatColors.danger),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: NamatSpace.xl),
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.icon,
    required this.accent,
    required this.tint,
    required this.arabic,
    required this.current,
    required this.hasOther,
    required this.onChoose,
  });

  final NamatPackage package;
  final NamatIcons icon;
  final Color accent;
  final Color tint;
  final bool arabic;
  final bool current;

  /// The member is on a different package, so this button is a switch rather
  /// than a first subscription — and it says so.
  final bool hasOther;

  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return NamatCard(
      organic: true,
      color: tint,
      padding: const EdgeInsets.all(NamatSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Sized to what is in it. A package with four benefits is taller than
        // one with three, and that is the honest shape for it to be.
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              NamatIcon(icon, size: 34, color: accent),
              const Spacer(),
              if (current)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: NamatColors.surface,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    l.currentPackage,
                    style: text.labelSmall?.copyWith(color: accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: NamatSpace.xl),
          Text(package.localisedName(arabic), style: text.displayMedium),
          const SizedBox(height: 4),
          Text(package.localisedBestFor(arabic), style: text.bodySmall),
          const SizedBox(height: NamatSpace.xl),
          for (final b in package.localisedBenefits(arabic))
            Padding(
              padding: const EdgeInsets.only(bottom: NamatSpace.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: NamatSpace.sm),
                  Expanded(child: Text(b, style: text.bodyMedium)),
                ],
              ),
            ),
          const SizedBox(height: NamatSpace.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                context.n(package.monthlyPrice),
                style: text.displayLarge,
              ),
              const SizedBox(width: 6),
              Text('${l.omr} · ${l.perMonth}', style: text.bodySmall),
            ],
          ),
          const SizedBox(height: NamatSpace.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: current ? null : onChoose,
              style: FilledButton.styleFrom(backgroundColor: accent),
              child: Text(
                current
                    ? l.currentPackage
                    : hasOther
                        ? l.upgradeMembership
                        : l.startPackage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
