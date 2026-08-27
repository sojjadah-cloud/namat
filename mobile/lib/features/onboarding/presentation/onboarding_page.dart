import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';

/// Three screens, one idea each.
///
/// Every illustration is drawn from the icon family rather than an imported
/// asset: they animate, they inherit the palette, and they cannot fall out of
/// step with the brand the way a static export does.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final last = _index == 2;

    final slides = [
      (l.onbTitle1, const _OrbitArt()),
      (l.onbTitle2, const _PathArt()),
      (l.onbTitle3, const _DuelArt()),
    ];

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => context.go('/welcome'),
                  child: Text(l.onbSkip),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pages,
                  itemCount: slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: NamatSpace.xxl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 220, child: slides[i].$2),
                        const SizedBox(height: NamatSpace.section),
                        Text(
                          slides[i].$1,
                          style: text.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < slides.length; i++)
                    AnimatedContainer(
                      duration: NamatMotion.base,
                      curve: NamatMotion.enter,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: i == _index ? 22 : 6,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? NamatColors.deep
                            : NamatColors.line,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(NamatSpace.gutter),
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () => last
                          ? context.go('/welcome')
                          : _pages.nextPage(
                              duration: NamatMotion.base,
                              curve: NamatMotion.enter,
                            ),
                      child: Text(last ? l.onbStart : l.explore),
                    ),
                    const SizedBox(height: NamatSpace.sm),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(l.onbHaveAccount),
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

/// Four services orbiting the mark — the ecosystem, in one shape.
class _OrbitArt extends StatefulWidget {
  const _OrbitArt();

  @override
  State<_OrbitArt> createState() => _OrbitArtState();
}

class _OrbitArtState extends State<_OrbitArt>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const icons = [
      (NamatIcons.meals, NamatColors.food),
      (NamatIcons.fitness, NamatColors.fitness),
      (NamatIcons.consultation, NamatColors.nutrition),
      (NamatIcons.store, NamatColors.products),
    ];

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => SizedBox.square(
        dimension: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: NamatColors.line),
              ),
              child: const SizedBox.square(dimension: 176),
            ),
            const NamatLogoMark(size: 62),
            for (var i = 0; i < icons.length; i++)
              Transform.translate(
                // Slow enough to read as drift rather than as spinning.
                offset: Offset.fromDirection(
                  (_c.value * 2 * math.pi) + (i / icons.length) * 2 * math.pi,
                  88,
                ),
                child: Container(
                  padding: const EdgeInsets.all(11),
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
                  child: NamatIcon(icons[i].$1, size: 22, color: icons[i].$2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A journey path with milestones filling along it.
class _PathArt extends StatelessWidget {
  const _PathArt();

  @override
  Widget build(BuildContext context) {
    const stops = [
      (NamatIcons.leaf, NamatColors.accent),
      (NamatIcons.meals, NamatColors.food),
      (NamatIcons.fitness, NamatColors.fitness),
      (NamatIcons.consultation, NamatColors.nutrition),
      (NamatIcons.reward, NamatColors.gold),
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: NamatMotion.curve,
      builder: (context, v, _) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < stops.length; i++)
            Opacity(
              opacity: (v * stops.length - i).clamp(0, 1),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: stops[i].$2.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: NamatIcon(stops[i].$1, size: 18, color: stops[i].$2),
                  ),
                  if (i < stops.length - 1)
                    Container(width: 2, height: 14, color: NamatColors.line),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Two people joined by an energy line — the shape of a duel.
class _DuelArt extends StatelessWidget {
  const _DuelArt();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: NamatMotion.curve,
      builder: (context, v, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Node(colour: NamatColors.accent, shift: -30 * (1 - v)),
          SizedBox(
            width: 74,
            child: Column(
              children: [
                Container(
                  height: 3,
                  width: 74 * v,
                  decoration: BoxDecoration(
                    color: NamatColors.sageLight,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),
          _Node(colour: NamatColors.pilates, shift: 30 * (1 - v)),
        ],
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.colour, required this.shift});

  final Color colour;
  final double shift;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(shift, 0),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: colour.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: colour.withOpacity(0.4), width: 2),
        ),
        child: NamatIcon(NamatIcons.profile, size: 30, color: colour),
      ),
    );
  }
}
