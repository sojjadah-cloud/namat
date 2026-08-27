import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';

/// The pre-login screen.
///
/// Not a form with a headline above it. The ecosystem drifts slowly at the
/// centre — five services orbiting the mark — because the thing being sold is
/// that they are one product, and a list of four bullet points does not say
/// that.
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  )..repeat();

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: NamatSpace.xl),
              const NamatLogoMark(size: 46),
              const SizedBox(height: NamatSpace.xl),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NamatSpace.xxl,
                ),
                child: Column(
                  children: [
                    Text(
                      l.welcomeHeadline,
                      style: text.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: NamatSpace.md),
                    Text(
                      l.welcomeSub,
                      style: text.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _drift,
                    builder: (context, _) => _Ecosystem(t: _drift.value),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(NamatSpace.gutter),
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () => context.go('/signup'),
                      child: Text(l.createAccount),
                    ),
                    const SizedBox(height: NamatSpace.md),
                    OutlinedButton(
                      onPressed: () => context.go('/login'),
                      child: Text(l.login),
                    ),
                    const SizedBox(height: NamatSpace.md),
                    TextButton(
                      onPressed: () => context.go('/explore'),
                      child: Text(
                        l.exploreAsGuest,
                        style: text.labelMedium?.copyWith(
                          color: NamatColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ecosystem extends StatelessWidget {
  const _Ecosystem({required this.t});

  /// 0–1 around the orbit.
  final double t;

  @override
  Widget build(BuildContext context) {
    const orbiting = [
      (NamatIcons.meals, NamatColors.food),
      (NamatIcons.fitness, NamatColors.fitness),
      (NamatIcons.consultation, NamatColors.nutrition),
      (NamatIcons.store, NamatColors.products),
      (NamatIcons.challenge, NamatColors.pilates),
    ];

    return SizedBox.square(
      dimension: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final r in [78.0, 108.0])
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: NamatColors.line.withOpacity(0.7),
                ),
              ),
              child: SizedBox.square(dimension: r * 2),
            ),
          const NamatLogoMark(size: 58),
          for (var i = 0; i < orbiting.length; i++)
            Transform.translate(
              // Alternating radii so the icons do not read as a single ring,
              // and a per-icon phase so they never line up.
              offset: Offset.fromDirection(
                (t * 2 * math.pi) + (i / orbiting.length) * 2 * math.pi,
                i.isEven ? 108 : 78,
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: NamatColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x142F4F4A),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: NamatIcon(
                  orbiting[i].$1,
                  size: 20,
                  color: orbiting[i].$2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
