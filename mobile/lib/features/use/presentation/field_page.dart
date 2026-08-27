import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/arabic.dart';
import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/domain/city.dart';
import '../../account/domain/session.dart';
import '../../catalogue/domain/catalogue.dart';
import '../../favorites/domain/favorites.dart';
import '../../favorites/presentation/favorites_page.dart' show FavouriteButton;
import '../domain/field.dart';

/// One field: search and filters scoped to it.
///
/// Search only exists here, never on the page before — and it only ever
/// queries this field, so "بروتين" inside meals finds kitchens and the same
/// word inside stores finds supplements, with no way for an unrelated result
/// to appear.
class FieldPage extends ConsumerStatefulWidget {
  const FieldPage({super.key, required this.fieldKey});

  final String fieldKey;

  @override
  ConsumerState<FieldPage> createState() => _FieldPageState();
}

class _FieldPageState extends ConsumerState<FieldPage> {
  final _search = TextEditingController();
  final _active = <String>{};

  /// Set when the member asks to see a city that is not theirs, so the choice
  /// lasts while they browse and does not follow them to the next field.
  NamatCity? _viewing;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Matches a partner on its own name, its area, its tags, and the names of
  /// the things it sells.
  ///
  /// The last one matters more than it looks: nobody searches for "Macro
  /// Boost", they search for "بروتين", and a partner whose only protein
  /// reference is on its menu would otherwise be unfindable.
  List<Partner> _filter(List<Partner> partners, L l, bool arabic) {
    final q = _search.text.trim();

    var results = q.isEmpty
        ? partners
        : partners.where((p) {
            final haystack = [
              p.name,
              p.nameEn,
              p.area,
              p.areaEn,
              ...p.tags,
              ...p.tagsEn,
              for (final o in p.offerings) ...[o.name, o.nameEn],
            ].join(' ');
            return matchesArabic(haystack, q);
          }).toList();

    // Filters narrow; they do not reorder, except the two that are explicitly
    // about order.
    if (_active.contains(l.filterSubscriptions)) {
      results = results
          .where((p) => p.offerings.any((o) =>
              o.kind == OfferingKind.plan || o.kind == OfferingKind.pass))
          .toList();
    }
    if (_active.contains(l.filterHighProtein)) {
      results = results
          .where((p) => p.offerings
              .any((o) => (o.nutrition?.protein ?? 0) >= 30))
          .toList();
    }
    if (_active.contains(l.filterNearest)) {
      results = [...results]
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }
    if (_active.contains(l.filterTopRated)) {
      // Partners with no rating go last rather than being treated as zero:
      // unrated is not badly rated.
      results = [...results]..sort((a, b) {
          final ra = a.rating, rb = b.rating;
          if (ra == null && rb == null) return 0;
          if (ra == null) return 1;
          if (rb == null) return -1;
          return rb.compareTo(ra);
        });
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final field = NamatField.byKey(widget.fieldKey);

    if (field == null) {
      return Scaffold(
        appBar: AppBar(),
        body: NamatEmptyState(title: l.errorTitle, body: l.errorBody),
      );
    }

    final home = ref.watch(sessionProvider).city;
    final city = _viewing ?? home;
    final all = Catalogue.inCity(field, city);
    final results = _filter(all, l, arabic);

    // Where else this field exists, for the member whose own city has nothing
    // in it yet. Sohar is the launch market and the researched catalogue is
    // Muscat, so this is a state members will actually meet.
    final elsewhere =
        Catalogue.citiesWith(field).where((c) => c != city).toList();

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/explore'),
            icon: const Icon(Icons.arrow_forward),
          ),
          title: Row(
            children: [
              // The icon flies from the card into this header.
              Hero(
                tag: 'field-${field.name}',
                child: NamatIcon(field.icon, size: 24, color: field.accent),
              ),
              const SizedBox(width: NamatSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(field.title(l)),
                    // Only when it differs from theirs. Labelling every list
                    // with the member's own city is noise.
                    if (city != home)
                      Text(
                        l.inCity(city.label(l)),
                        style: text.labelSmall,
                      ),
                  ],
                ),
              ),
              if (city != home)
                TextButton(
                  onPressed: () => setState(() => _viewing = null),
                  child: Text(home.label(l)),
                ),
            ],
          ),
        ),
        body: all.isEmpty
            // A search box above an empty list looks broken rather than empty,
            // so it is not rendered at all in this state. And the member is
            // told which city they are in and offered one that has something,
            // rather than left to conclude the app is broken.
            ? NamatEmptyState(
                illustration: NamatIcon(
                  field.icon,
                  size: 56,
                  color: NamatColors.inkSoft,
                ),
                title: l.noPartnersInCity(city.label(l)),
                body: l.noPartnersInCityBody,
                action: elsewhere.isEmpty
                    ? FilledButton(
                        onPressed: () => context.go('/explore'),
                        child: Text(l.useNamatCta),
                      )
                    : FilledButton(
                        onPressed: () =>
                            setState(() => _viewing = elsewhere.first),
                        child:
                            Text(l.showCity(elsewhere.first.label(l))),
                      ),
              )
            : ListView(
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
                      hintText: field.searchHint(l),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(14),
                        child: NamatIcon(
                          NamatIcons.search,
                          size: 20,
                          color: NamatColors.inkSoft,
                        ),
                      ),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => setState(_search.clear),
                            ),
                    ),
                  ),
                  const SizedBox(height: NamatSpace.md),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: field.filters(l).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final label = field.filters(l)[i];
                        final on = _active.contains(label);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (on) {
                              _active.remove(label);
                            } else {
                              _active.add(label);
                            }
                          }),
                          child: AnimatedContainer(
                            duration: NamatMotion.fast,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: on
                                  ? NamatColors.deep
                                  : NamatColors.warmSoft,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              label,
                              style: text.labelMedium?.copyWith(
                                color: on ? Colors.white : NamatColors.inkSoft,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: NamatSpace.xl),
                  if (results.isEmpty)
                    // A search that found nothing is a different state from a
                    // field with no partners, and says so.
                    Padding(
                      padding: const EdgeInsets.only(top: NamatSpace.section),
                      child: NamatEmptyState(
                        illustration: const NamatIcon(
                          NamatIcons.search,
                          size: 48,
                          color: NamatColors.inkSoft,
                        ),
                        title: l.noResults,
                        body: l.noResultsBody,
                      ),
                    )
                  else ...[
                    Text(
                      l.resultCount(context.n(results.length)),
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: NamatSpace.md),
                    for (final (i, p) in results.indexed) ...[
                      Reveal(
                        index: i,
                        // Re-keyed on the query so filtering re-animates
                        // rather than swapping text inside stationary cards.
                        key: ValueKey('${p.slug}-${_search.text}'),
                        child: _ResultCard(
                          partner: p,
                          field: field,
                          fieldKey: widget.fieldKey,
                          arabic: arabic,
                        ),
                      ),
                      const SizedBox(height: NamatSpace.md),
                    ],
                  ],
                ],
              ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.partner,
    required this.field,
    required this.fieldKey,
    required this.arabic,
  });

  final Partner partner;
  final NamatField field;
  final String fieldKey;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final name = partner.localisedName(arabic);
    final tags = partner.localisedTags(arabic);
    final from = partner.fromPrice;

    return NamatCard(
      padding: const EdgeInsets.all(NamatSpace.md),
      onTap: () => context.go('/explore/$fieldKey/partner/${partner.slug}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: field.tint,
              borderRadius: BorderRadius.circular(NamatRadius.xs),
            ),
            child: Text(
              monogram(name),
              style: text.titleLarge?.copyWith(color: field.accent),
            ),
          ),
          const SizedBox(width: NamatSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: text.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FavouriteButton(
                      kind: FavouriteKind.partner,
                      id: partner.slug,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${tags.join(' · ')} · ${partner.localisedArea(arabic)}',
                  style: text.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Wrap: distance, price and service count are three facts, and
                // a Row drops the last one off the edge at 360dp.
                Wrap(
                  spacing: 0,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const NamatIcon(
                      NamatIcons.location,
                      size: 14,
                      color: NamatColors.inkSoft,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${context.n(partner.distanceKm)} ${l.km}',
                      style: text.labelSmall,
                    ),
                    if (from != null) ...[
                      const SizedBox(width: 10),
                      Text(
                        l.fromPrice(context.money(from), l.omr),
                        style: text.labelSmall,
                      ),
                    ],
                    const SizedBox(width: 10),
                    Text(
                      l.serviceCount(context.n(partner.offerings.length)),
                      style: text.labelSmall,
                    ),
                  ],
                ),
                if (!partner.hasAnythingAvailable) ...[
                  const SizedBox(height: 6),
                  // Said on the list rather than discovered on the page. A
                  // member should not have to open a partner to learn there
                  // is nothing there to book.
                  Text(
                    l.everythingUnavailable,
                    style: text.labelSmall
                        ?.copyWith(color: NamatColors.danger),
                  ),
                ],
                if (partner.inPackage) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const NamatIcon(
                        NamatIcons.leaf,
                        size: 13,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Initials stand in for a logo. A partner's trademark is theirs to give, and
/// a stock photo pretending to be their shopfront is a false claim.
String monogram(String name) {
  final words = name.split(' ').where((w) => w.length > 1).toList();
  if (words.isEmpty) return '؟';
  final first = words.first;
  if (RegExp(r'[؀-ۿ]').hasMatch(first)) {
    // Skip the definite article, or every name beginning "ال" monograms to
    // the same alef.
    final stem =
        first.startsWith('ال') && first.length > 3 ? first.substring(2) : first;
    return stem.substring(0, 1);
  }
  return words.length > 1
      ? (first[0] + words[1][0]).toUpperCase()
      : first.substring(0, 2).toUpperCase();
}
