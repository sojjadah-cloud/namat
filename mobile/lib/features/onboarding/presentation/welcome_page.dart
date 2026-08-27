import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../core/widgets/namat_skyline.dart';
import '../../../l10n/app_localizations.dart';

/// The pre-login screen, built to the brand board.
///
/// The composition is the board's: the mark alone in the leading top corner, a
/// soft green sweep weighting the opposite one, and the Omani seafront drawn
/// in one hairline along the bottom — the fort, the port cranes, a dhow, the
/// palms and the minaret. Sohar is where NAMAT launches, and that horizon is
/// what the product is for.
///
/// Everything between them is left as paper. The previous version filled that
/// space with five orbiting service icons, which explained the ecosystem to
/// somebody who had not yet asked what it was; the board's own answer is
/// quieter and better, so the middle now holds one sentence and two buttons.
///
/// Every line is painted rather than shipped as an asset: it takes the theme's
/// colours, scales to any width without a second file, and adds nothing to the
/// download — which on a first screen, on a phone, on a slow connection, is
/// the entire argument.
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return NamatBackground(
      // The bloom is off: the sweep and the horizon are the composition, and a
      // third soft shape behind them turns three deliberate marks into haze.
      bloom: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ------------------------------------------------ the sweep, top
            const Align(
              alignment: Alignment.topCenter,
              child: NamatCornerSweep(height: 230),
            ),

            // --------------------------------------------- the coast, bottom
            //
            // Drawn behind the buttons and given its own height rather than
            // being sized by the Stack, so the horizon sits at a fixed
            // distance from the bottom edge on every screen instead of
            // stretching on a tall one.
            Align(
              alignment: Alignment.bottomCenter,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _entry,
                  // Arrives last and slowest. It is the setting, not the
                  // subject, and a horizon that races in reads as a banner.
                  curve: const Interval(0.35, 1, curve: Curves.easeOut),
                ),
                child: const SizedBox(
                  height: 210,
                  width: double.infinity,
                  child: NamatSkyline(),
                ),
              ),
            ),

            // ------------------------------------------------------ the page
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NamatSpace.gutter,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: NamatSpace.xl),
                    // Leading corner, alone, exactly as on the board.
                    const NamatLogoMark(size: 52),

                    const Spacer(flex: 2),

                    ...revealAll([
                      Text(l.welcomeHeadline, style: text.displayLarge),
                      const SizedBox(height: NamatSpace.md),
                      SizedBox(
                        width: 340,
                        child: Text(
                          l.welcomeSub,
                          style: text.bodyMedium?.copyWith(
                            color: NamatColors.inkSoft,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ]),

                    const Spacer(flex: 3),

                    // The two doors, and a third way in that needs neither.
                    FilledButton(
                      onPressed: () => context.go('/signup'),
                      child: Text(l.createAccount),
                    ),
                    const SizedBox(height: NamatSpace.sm),
                    OutlinedButton(
                      onPressed: () => context.go('/login'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: NamatColors.line),
                      ),
                      child: Text(l.login),
                    ),
                    const SizedBox(height: NamatSpace.xs),
                    Center(
                      child: TextButton(
                        // Browsing needs no account, and saying so here is
                        // what keeps the catalogue reachable by anyone who has
                        // not decided yet.
                        onPressed: () => context.go('/home'),
                        child: Text(l.exploreAsGuest),
                      ),
                    ),
                    const SizedBox(height: NamatSpace.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
