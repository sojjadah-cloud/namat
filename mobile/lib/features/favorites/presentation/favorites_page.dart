import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../catalogue/domain/catalogue.dart';
import '../domain/favorites.dart';

/// Everything the member has saved, in one place.
///
/// Grouped by kind rather than split into separate screens. Nobody thinks "my
/// saved gyms" and "my saved dishes" as two lists; they think "the things I
/// liked", and a tab bar over four near-empty lists is worse than one page
/// with headings.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final saved = ref.watch(favouritesProvider);

    // A saved id whose partner has since left the catalogue is dropped rather
    // than rendered as a blank row.
    final partners = [
      for (final id in saved
          .where((f) => f.kind == FavouriteKind.partner)
          .map((f) => f.id))
        if (Catalogue.bySlug(id) case final p?) p,
    ];
    final services = [
      for (final id in saved
          .where((f) => f.kind == FavouriteKind.offering)
          .map((f) => f.id))
        if (Catalogue.offeringById(id) case final o?)
          if (Catalogue.partnerOf(id) case final p?) (p, o),
    ];

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const NamatBack(fallback: '/profile'),
          title: Text(l.favoritesTitle),
        ),
        body: saved.isEmpty
            ? NamatEmptyState(
                illustration: const Icon(
                  Icons.favorite_border,
                  size: 48,
                  color: NamatColors.inkSoft,
                ),
                title: l.favoritesEmpty,
                body: l.favoritesEmptyBody,
                action: FilledButton(
                  onPressed: () => context.go('/explore'),
                  child: Text(l.explore),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  NamatSpace.gutter,
                  NamatSpace.lg,
                  NamatSpace.gutter,
                  120,
                ),
                children: revealAll([
                  if (partners.isNotEmpty) ...[
                    Text(l.savedPartners, style: text.labelMedium),
                    const SizedBox(height: NamatSpace.sm),
                    for (final p in partners)
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
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: p.field.tint,
                                  borderRadius:
                                      BorderRadius.circular(NamatRadius.xs),
                                ),
                                child: NamatIcon(
                                  p.field.icon,
                                  size: 20,
                                  color: p.field.accent,
                                ),
                              ),
                              const SizedBox(width: NamatSpace.md),
                              Expanded(
                                child: Text(
                                  p.localisedName(arabic),
                                  style: text.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _Unsave(
                                kind: FavouriteKind.partner,
                                id: p.slug,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: NamatSpace.lg),
                  ],
                  if (services.isNotEmpty) ...[
                    Text(l.savedServices, style: text.labelMedium),
                    const SizedBox(height: NamatSpace.sm),
                    for (final (p, o) in services)
                      Padding(
                        padding: const EdgeInsets.only(bottom: NamatSpace.sm),
                        child: NamatCard(
                          padding: const EdgeInsets.all(NamatSpace.md),
                          onTap: () => context.go(
                            '/explore/${p.field.name}/partner/${p.slug}',
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      o.localisedName(arabic),
                                      style: text.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${p.localisedName(arabic)} · '
                                      '${context.money(o.price)} ${l.omr}',
                                      style: text.labelSmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              _Unsave(
                                kind: FavouriteKind.offering,
                                id: o.id,
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

class _Unsave extends ConsumerWidget {
  const _Unsave({required this.kind, required this.id});

  final FavouriteKind kind;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;

    return IconButton(
      tooltip: l.saved,
      onPressed: () {
        ref.read(favouritesProvider.notifier).toggle(kind, id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.removedFromSaved),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      icon: const Icon(
        Icons.favorite,
        size: 20,
        color: NamatColors.danger,
      ),
    );
  }
}

/// The heart, wherever something can be saved.
///
/// Its own widget so the animation and the guest gate are written once. A
/// heart that behaves differently on two screens is the kind of inconsistency
/// members notice without being able to name.
class FavouriteButton extends ConsumerWidget {
  const FavouriteButton({
    super.key,
    required this.kind,
    required this.id,
    this.size = 20,
  });

  final FavouriteKind kind;
  final String id;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(isFavouriteProvider(Favourite(kind, id)));

    return IconButton(
      onPressed: () => ref.read(favouritesProvider.notifier).toggle(kind, id),
      icon: AnimatedScale(
        // A small overshoot on save and nothing on unsave: the feedback is
        // for the commitment, not for the withdrawal.
        scale: saved ? 1.12 : 1,
        duration: NamatMotion.fast,
        curve: NamatMotion.enter,
        child: Icon(
          saved ? Icons.favorite : Icons.favorite_border,
          size: size,
          color: saved ? NamatColors.danger : NamatColors.inkSoft,
        ),
      ),
    );
  }
}
