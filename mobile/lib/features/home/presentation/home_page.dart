import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../account/domain/session.dart';
import '../../bookings/domain/cart_notifier.dart';
import '../../catalogue/domain/catalogue.dart';
import '../../use/domain/field.dart';
import '../domain/home_feed.dart';

/// Home: a dashboard, not a directory.
///
/// The order is the design, and it is deliberate: where you are, how the week
/// is going, the one thing to do next, then the four worlds, then things
/// chosen for you. A promotional banner at the top would be the obvious
/// commercial choice and the wrong one — the first thing a member sees should
/// be their own progress, because the product's claim is that it helps them
/// continue, not that it has offers.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final evening = DateTime.now().hour >= 16;

    final name = ref.watch(greetingNameProvider);
    final session = ref.watch(sessionProvider);
    final cartCount = ref.watch(cartCountProvider);
    final recommended = ref.watch(recommendedProvider).take(4).toList();
    final nearby = ref.watch(nearbyProvider).take(3).toList();

    return NamatBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.lg,
            NamatSpace.gutter,
            120,
          ),
          children: revealAll([
            // ------------------------------------------------------ header
            Row(
              children: [
                NamatAvatar(name: name),
                const SizedBox(width: NamatSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // A blank name is greeted without one rather than
                        // addressed as an empty string.
                        name.isEmpty
                            ? l.useGreeting
                            : evening
                                ? l.greetingEvening(name)
                                : l.greetingMorning(name),
                        style: text.titleMedium,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 2),
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
                IconButton(
                  onPressed: () => context.go('/search'),
                  icon: const NamatIcon(NamatIcons.search, size: 22),
                ),
                // Only once there is something in it. A permanently visible
                // empty cart is a button that never does anything.
                if (cartCount > 0) _CartButton(count: cartCount),
                IconButton(
                  onPressed: () => context.go('/home/notifications'),
                  icon: const NamatIcon(NamatIcons.bell, size: 22),
                ),
              ],
            ),

            // -------------------------------------------- journey progress
            const SizedBox(height: NamatSpace.xl),
            const _WeekCard(),

            // ---------------------------------------------------- next step
            const SizedBox(height: NamatSpace.lg),
            const _NextStepCard(),

            // -------------------------------------------------- use namat
            const SizedBox(height: NamatSpace.xxl),
            Text(l.useGreeting, style: text.titleMedium),
            const SizedBox(height: NamatSpace.md),
            const _Worlds(),

            // -------------------------------------------------- recommended
            if (recommended.isNotEmpty) ...[
              const SizedBox(height: NamatSpace.xxl),
              _SectionHeading(
                label: l.recommendedForYou,
                onSeeAll: () => context.go('/explore'),
              ),
              const SizedBox(height: NamatSpace.md),
              SizedBox(
                height: 132,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommended.length,
                  clipBehavior: Clip.none,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: NamatSpace.md),
                  itemBuilder: (context, i) {
                    final (p, o) = recommended[i];
                    return _ServiceCard(partner: p, offering: o, arabic: arabic);
                  },
                ),
              ),
            ],

            // --------------------------------------------------- challenges
            const SizedBox(height: NamatSpace.xxl),
            _SectionHeading(
              label: l.challengesTitle,
              onSeeAll: () => context.go('/journey/challenges'),
            ),
            const SizedBox(height: NamatSpace.md),
            NamatCard(
              color: NamatColors.pilatesSoft,
              elevated: false,
              padding: const EdgeInsets.all(NamatSpace.lg),
              onTap: () => context.go('/journey/challenges'),
              child: Row(
                children: [
                  const NamatIcon(
                    NamatIcons.challenge,
                    size: 24,
                    color: NamatColors.pilates,
                  ),
                  const SizedBox(width: NamatSpace.md),
                  Expanded(
                    child: Text(l.challengesHero, style: text.bodyMedium),
                  ),
                  const Icon(
                    Icons.chevron_left,
                    size: 18,
                    color: NamatColors.inkSoft,
                  ),
                ],
              ),
            ),

            // ------------------------------------------------------ bundles
            const SizedBox(height: NamatSpace.xxl),
            _SectionHeading(
              label: l.bundlesPreview,
              onSeeAll: () => context.go('/journey/packages'),
            ),
            const SizedBox(height: NamatSpace.md),
            NamatCard(
              color: NamatColors.greenSoft,
              elevated: false,
              padding: const EdgeInsets.all(NamatSpace.lg),
              onTap: () => context.go('/journey/packages'),
              child: Row(
                children: [
                  const NamatIcon(
                    NamatIcons.package,
                    size: 24,
                    color: NamatColors.deep,
                  ),
                  const SizedBox(width: NamatSpace.md),
                  Expanded(child: Text(l.packagesSub, style: text.bodyMedium)),
                  const Icon(
                    Icons.chevron_left,
                    size: 18,
                    color: NamatColors.inkSoft,
                  ),
                ],
              ),
            ),

            // ------------------------------------------------------- nearby
            if (nearby.isNotEmpty) ...[
              const SizedBox(height: NamatSpace.xxl),
              _SectionHeading(
                label: l.nearYou,
                onSeeAll: () => context.go('/explore'),
              ),
              const SizedBox(height: NamatSpace.md),
              for (final p in nearby)
                Padding(
                  padding: const EdgeInsets.only(bottom: NamatSpace.sm),
                  child: NamatCard(
                    padding: const EdgeInsets.all(NamatSpace.md),
                    onTap: () => context.go(
                      '/explore/${p.field.name}/partner/${p.slug}',
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: p.field.tint,
                            borderRadius:
                                BorderRadius.circular(NamatRadius.xs),
                          ),
                          child: NamatIcon(
                            p.field.icon,
                            size: 19,
                            color: p.field.accent,
                          ),
                        ),
                        const SizedBox(width: NamatSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.localisedName(arabic),
                                style: text.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${p.localisedArea(arabic)} · '
                                '${context.n(p.distanceKm)} ${l.km}',
                                style: text.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ]),
        ),
      ),
    );
  }

}

/// The week, as a ring with three arcs under it.
///
/// A single number is a verdict; the arcs show which part is carrying it and
/// which is not, which is the difference between a score you argue with and
/// one you act on.
class _WeekCard extends ConsumerWidget {
  const _WeekCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final progress = ref.watch(weekProgressProvider);
    final percent = (progress * 100).round();

    return NamatCard(
      organic: true,
      onTap: () => context.go('/journey'),
      child: Column(
        children: [
          NamatProgressRing(
            value: progress,
            size: 148,
            stroke: 11,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  // Derived, not decorative: a new member sees zero rather
                  // than a stranger's 72%.
                  context.n(percent),
                  style: text.displayLarge?.copyWith(fontSize: 40),
                ),
                Text(l.thisWeek, style: text.labelSmall),
              ],
            ),
          ),
          const SizedBox(height: NamatSpace.md),
          Text(
            l.weekProgress(context.n(percent)),
            style: text.bodySmall?.copyWith(color: NamatColors.accent),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: NamatSpace.xl),
          Row(
            children: [
              _Arc(label: l.arcNutrition, value: 0.6, color: NamatColors.food),
              _Arc(
                label: l.arcMovement,
                value: 0.8,
                color: NamatColors.fitness,
              ),
              _Arc(
                label: l.arcHydration,
                value: 0.75,
                color: NamatColors.nutrition,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Arc extends StatelessWidget {
  const _Arc({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          NamatProgressRing(
            value: value,
            size: 46,
            stroke: 5,
            color: color,
            track: color.withOpacity(0.15),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// One thing to do next — never a list of six.
class _NextStepCard extends ConsumerWidget {
  const _NextStepCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final step = ref.watch(nextStepProvider);

    final (title, body, route, colour, icon) = switch (step.kind) {
      NextStepKind.upcoming => (
          l.nextStep,
          '${step.order!.leadTitle} · ${context.dateTime(step.at!)}',
          '/bookings',
          NamatColors.greenSoft,
          Icons.event_available,
        ),
      NextStepKind.rate => (
          l.rateTitle,
          step.order!.leadTitle,
          '/rate/${step.order!.reference}',
          NamatColors.goldSoft,
          Icons.star_rounded,
        ),
      NextStepKind.cart => (
          l.cartTitle,
          l.checkout,
          '/cart',
          NamatColors.warmSoft,
          Icons.shopping_bag_outlined,
        ),
      NextStepKind.suggestion => (
          l.namatPicks,
          '${step.offering!.localisedName(arabic)} · '
              '${step.partner!.localisedName(arabic)}',
          '/explore/${step.partner!.field.name}/partner/'
              '${step.partner!.slug}',
          NamatColors.sageSoft,
          Icons.auto_awesome,
        ),
      NextStepKind.none => (
          l.noNextStep,
          l.noNextStepBody,
          '/explore',
          NamatColors.warmSoft,
          Icons.explore_outlined,
        ),
    };

    return NamatCard(
      color: colour,
      elevated: false,
      padding: const EdgeInsets.all(NamatSpace.lg),
      onTap: () => context.go(route),
      child: Row(
        children: [
          Icon(icon, size: 22, color: NamatColors.deep),
          const SizedBox(width: NamatSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.labelMedium),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: text.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_left,
            size: 18,
            color: NamatColors.inkSoft,
          ),
        ],
      ),
    );
  }
}

/// The four worlds, one large card each.
class _Worlds extends StatelessWidget {
  const _Worlds();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        for (final field in NamatField.values)
          Padding(
            padding: const EdgeInsets.only(bottom: NamatSpace.md),
            child: NamatCard(
              color: field.tint,
              elevated: false,
              padding: const EdgeInsets.all(NamatSpace.lg),
              onTap: () => context.go('/explore/${field.name}'),
              child: Row(
                children: [
                  Hero(
                    tag: 'field-${field.name}',
                    child: NamatIcon(
                      field.icon,
                      size: 28,
                      color: field.accent,
                    ),
                  ),
                  const SizedBox(width: NamatSpace.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(field.title(l), style: text.titleMedium),
                        const SizedBox(height: 2),
                        Text(field.subtitle(l), style: text.labelSmall),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_left,
                    size: 18,
                    color: field.accent,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label, required this.onSeeAll});

  final String label;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(child: Text(label, style: text.titleMedium)),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
          ),
          child: Text(l.seeAll),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.partner,
    required this.offering,
    required this.arabic,
  });

  final Partner partner;
  final Offering offering;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final covered = offering.coveredByPackage && partner.inPackage;

    return SizedBox(
      width: 200,
      child: NamatCard(
        padding: const EdgeInsets.all(NamatSpace.lg),
        onTap: () => context.go(
          '/explore/${partner.field.name}/partner/${partner.slug}',
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NamatIcon(
                  partner.field.icon,
                  size: 20,
                  color: partner.field.accent,
                ),
                const SizedBox(height: NamatSpace.sm),
                Text(
                  offering.localisedName(arabic),
                  style: text.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Text(
              covered
                  ? l.freeFromPackage
                  : '${context.money(offering.price)} ${l.omr}',
              style: text.labelSmall?.copyWith(
                color: covered ? NamatColors.accent : NamatColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () => context.go('/cart'),
          icon: const NamatIcon(NamatIcons.store, size: 22),
        ),
        Positioned(
          top: 6,
          // Placed by direction rather than by side, so the badge stays on the
          // outer corner of the icon in both layouts.
          right: Directionality.of(context) == TextDirection.rtl ? null : 6,
          left: Directionality.of(context) == TextDirection.rtl ? 6 : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: NamatColors.deep,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              context.n(count),
              style: text.labelSmall?.copyWith(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A monogram where a photograph would be.
///
/// A generated mark, never a stock portrait: a stranger's face standing in for
/// the member is a small lie the app tells every time it opens.
class NamatAvatar extends StatelessWidget {
  const NamatAvatar({super.key, required this.name, this.size = 42});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final initial = name.trim().isEmpty ? '؟' : name.trim().characters.first;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: NamatColors.greenSoft,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: text.titleMedium?.copyWith(color: NamatColors.deep),
      ),
    );
  }
}
