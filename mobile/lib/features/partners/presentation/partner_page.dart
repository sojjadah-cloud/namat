import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_art.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../core/widgets/namat_states.dart';
import '../../../l10n/app_localizations.dart';
import '../../bookings/domain/cart_notifier.dart';
import '../../catalogue/domain/catalogue.dart';
import '../../favorites/domain/favorites.dart';
import '../../favorites/presentation/favorites_page.dart' show FavouriteButton;
import '../../catalogue/presentation/offering_sheet.dart';
import '../../use/presentation/field_page.dart' show monogram;

/// A partner, and everything it sells.
///
/// Built to stay presentable when a business has given us nothing but a name.
/// Most partners in the Muscat catalogue have no photograph, no description
/// and no ratings — a page that needs those to look finished would look broken
/// for most of the list, so the header is a monogram on the field's own colour
/// and absent facts are simply absent rather than shown as zero.
class PartnerPage extends ConsumerWidget {
  const PartnerPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final p = Catalogue.bySlug(slug);

    // A slug that matches nothing is an error, not a reason to show some other
    // partner's page — which is what the previous fallback did.
    if (p == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const NamatBack(),
        ),
        body: NamatEmptyState(title: l.errorTitle, body: l.errorBody),
      );
    }

    final field = p.field;
    final cartCount = ref.watch(cartCountProvider);
    final tags = p.localisedTags(arabic);

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const NamatBack(),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            0,
            NamatSpace.gutter,
            140,
          ),
          children: revealAll([
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    NamatArt(
                      seed: p.slug,
                      accent: field.accent,
                      tint: field.tint,
                      size: 76,
                      radius: NamatRadius.sm,
                    ),
                    // The monogram stays on top: initials identify a business
                    // in a way an abstract mark cannot.
                    Text(
                      monogram(p.localisedName(arabic)),
                      style: text.displayMedium?.copyWith(color: field.accent),
                    ),
                  ],
                ),
                const SizedBox(width: NamatSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.localisedName(arabic),
                              style: text.titleLarge,
                            ),
                          ),
                          FavouriteButton(
                            kind: FavouriteKind.partner,
                            id: p.slug,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.firstParty ? l.firstPartyNote : field.title(l),
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const NamatIcon(
                            NamatIcons.location,
                            size: 14,
                            color: NamatColors.inkSoft,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              p.distanceKm == 0
                                  ? p.localisedArea(arabic)
                                  : '${p.localisedArea(arabic)} · '
                                      '${context.n(p.distanceKm)} ${l.km}',
                              style: text.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: NamatSpace.lg),
            // Nothing invented: a partner without ratings says so rather than
            // showing zero stars, which would misrepresent a real business.
            //
            // Wrap, not Row: "no ratings yet" beside "in your package" is 10
            // pixels too wide at 360dp, which is most Android phones, and a
            // Row would simply clip the second one off the screen.
            Wrap(
              spacing: NamatSpace.md,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (p.rating == null)
                  Text(l.partnerNoRating, style: text.labelSmall)
                else
                  Text(
                    l.ratingWithCount(
                      context.n(p.rating!),
                      context.n(p.reviewCount ?? 0),
                    ),
                    style: text.labelMedium,
                  ),
                if (p.inPackage)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const NamatIcon(
                        NamatIcons.leaf,
                        size: 14,
                        color: NamatColors.accent,
                        filled: true,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l.inYourPackage,
                        style: text.labelSmall?.copyWith(
                          color: NamatColors.accent,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: NamatSpace.xl),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in tags)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: field.tint,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        t,
                        style: text.labelSmall?.copyWith(color: field.accent),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: NamatSpace.xxl),
            Text(l.partnerAbout, style: text.labelMedium),
            const SizedBox(height: NamatSpace.sm),
            // A description is a business's own words. Writing one on their
            // behalf puts claims in their mouth, so a partner who has not
            // given us one shows that, not a paragraph we made up.
            Text(
              p.localisedAbout(arabic) ?? l.noDescription,
              style: text.bodySmall,
            ),
            const SizedBox(height: NamatSpace.lg),
            _Hours(hours: p.hours),
            if (p.phone != null) ...[
              const SizedBox(height: NamatSpace.md),
              // Expanded, not intrinsic: a Row hands its children unbounded
              // width, and an icon button that sizes to its label then asks
              // for infinity. Two equal halves is also the layout these two
              // want — neither is the primary action.
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      // No dialler is wired, and a button that silently
                      // does nothing is worse than one that says so.
                      onPressed: () => namatNotConnected(context),
                      icon: const Icon(Icons.call_outlined, size: 17),
                      label: Text(
                        l.callPartner,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: NamatSpace.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => namatNotConnected(context),
                      icon: const Icon(Icons.directions_outlined, size: 17),
                      label: Text(
                        l.directions,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: NamatSpace.xxl),
            Row(
              children: [
                Expanded(child: Text(l.partnerMenu, style: text.labelMedium)),
                Text(
                  l.serviceCount(context.n(p.offerings.length)),
                  style: text.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: NamatSpace.md),
            if (p.offerings.isEmpty)
              Text(l.noPartnersYet, style: text.bodySmall)
            else ...[
              if (!p.hasAnythingAvailable) ...[
                Text(l.everythingUnavailable, style: text.labelSmall),
                const SizedBox(height: NamatSpace.sm),
              ],
              for (final o in p.offerings)
                Padding(
                  padding: const EdgeInsets.only(bottom: NamatSpace.sm),
                  child: _OfferingRow(offering: o, partner: p, arabic: arabic),
                ),
            ],
          ]),
        ),
        bottomSheet: cartCount == 0
            ? null
            // Only once something is in the cart. An empty-cart bar sitting
            // over every partner page is a permanent piece of furniture that
            // says nothing.
            : Container(
                color: NamatColors.canvas,
                padding: const EdgeInsets.fromLTRB(
                  NamatSpace.gutter,
                  NamatSpace.md,
                  NamatSpace.gutter,
                  NamatSpace.xxl,
                ),
                child: FilledButton(
                  onPressed: () => context.go('/cart'),
                  child: Text(
                    '${l.viewCart} · ${l.itemsCount(context.n(cartCount))}',
                  ),
                ),
              ),
      ),
    );
  }
}

class _OfferingRow extends StatelessWidget {
  const _OfferingRow({
    required this.offering,
    required this.partner,
    required this.arabic,
  });

  final Offering offering;
  final Partner partner;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final o = offering;
    final note = o.localisedNote(arabic);
    final covered = o.coveredByPackage && partner.inPackage;
    final n = o.nutrition;

    final available = o.canBuy;
    final spots = o.availability?.spotsLeft;

    return Opacity(
      // Dimmed, not hidden. A member who came for this class needs to see it
      // is here and full, rather than doubt they remembered the app right.
      opacity: available ? 1 : 0.55,
      child: NamatCard(
        padding: const EdgeInsets.all(NamatSpace.lg),
        onTap: () => showOfferingSheet(
          context,
          offering: o,
          partner: partner,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A mark rather than a photograph. There is no photography for any
            // of this, and stock would be a claim about the partner's own
            // dish — so each item gets a composition drawn from its own id:
            // stable, distinct, and depicting nothing.
            NamatArt(
              seed: o.id,
              accent: partner.field.accent,
              tint: partner.field.tint,
              icon: partner.field.icon,
              size: 52,
            ),
            const SizedBox(width: NamatSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.localisedName(arabic), style: text.bodyMedium),
                  if (note != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      note,
                      style: text.labelSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 7),
                  // Wrap: the price, the package note and the macros are three
                  // independent facts, and on a narrow phone they need two
                  // lines. A Row pushed the macros off the edge entirely.
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${context.money(o.price)} ${l.omr}',
                        style: text.labelMedium?.copyWith(
                          color:
                              covered ? NamatColors.inkSoft : NamatColors.ink,
                          decoration:
                              covered ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (covered)
                        Text(
                          l.freeFromPackage,
                          style: text.labelSmall
                              ?.copyWith(color: NamatColors.accent),
                        ),
                      // Protein first because it is the number the members who
                      // filter on nutrition are actually filtering on.
                      if (n != null)
                        Text(
                          '${context.n(n.calories)} ${l.calories} · '
                          '${l.gramsShort(context.n(n.protein))} '
                          '${l.protein}',
                          style: text.labelSmall,
                        )
                      else if (o.minutes != null)
                        Text(
                          l.minutesShort(context.n(o.minutes!)),
                          style: text.labelSmall,
                        ),
                      // Only when it is nearly gone. A comfortable number is
                      // noise on a list of eight services.
                      if (available && spots != null && spots <= 3)
                        Text(
                          l.lastSpots(context.n(spots)),
                          style: text.labelSmall
                              ?.copyWith(color: NamatColors.danger),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: NamatSpace.sm),
            if (available)
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: partner.field.tint,
                  borderRadius: BorderRadius.circular(NamatRadius.xs),
                ),
                child: Icon(Icons.add, size: 18, color: partner.field.accent),
              )
            else
              Text(
                o.isSoldOut ? l.soldOut : l.outOfStock,
                style: text.labelSmall?.copyWith(color: NamatColors.danger),
              ),
          ],
        ),
      ),
    );
  }
}

/// Opening hours, or an honest gap where they would be.
class _Hours extends StatelessWidget {
  const _Hours({required this.hours});

  final OpeningHours? hours;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final h = hours;

    // A wrong closing time sends someone to a locked door, which is worse
    // than showing nothing at all.
    if (h == null) {
      return Text(l.hoursUnknown, style: text.labelSmall);
    }

    final open = h.isOpenAt(DateTime.now());

    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: open ? NamatColors.accent : NamatColors.inkSoft,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          open ? l.openNow : l.closedNow,
          style: text.labelSmall?.copyWith(
            color: open ? NamatColors.accent : NamatColors.inkSoft,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            // The clock is read, not transcribed, so its digits follow the
            // interface language like every other number on the page.
            l.hoursLine(
              context.digits(OpeningHours.format(h.opensAt)),
              context.digits(OpeningHours.format(h.closesAt)),
            ),
            style: text.labelSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
