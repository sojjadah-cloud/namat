import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/arabic.dart';
import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../catalogue/domain/catalogue.dart';

/// One search across the whole ecosystem.
///
/// Grouped by what a result is, not ranked into one list. "بروتين" matches a
/// kitchen, a gym's protein shake and a tub of whey, and flattening those into
/// one column makes the member read every row to work out which world each one
/// came from. The group heading answers that before they start.
///
/// Results are matched on folded Arabic, so `اطلس` finds `أطلس` — see
/// core/l10n/arabic.dart for why that mapping is written the way it is.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

typedef _Hit = (Partner partner, Offering offering);

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<Partner> _partners(String q) => Catalogue.all.where((p) {
        final haystack =
            [p.name, p.nameEn, p.area, p.areaEn, ...p.tags, ...p.tagsEn]
                .join(' ');
        return matchesArabic(haystack, q);
      }).toList();

  List<_Hit> _services(String q) => [
        for (final p in Catalogue.all)
          for (final o in p.offerings)
            if (matchesArabic('${o.name} ${o.nameEn}', q)) (p, o),
      ];

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final q = _controller.text.trim();

    final partners = q.isEmpty ? const <Partner>[] : _partners(q);
    final services = q.isEmpty ? const <_Hit>[] : _services(q);
    final nothing = q.isNotEmpty && partners.isEmpty && services.isEmpty;

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
            icon: const Icon(Icons.arrow_forward),
          ),
          title: Text(l.searchEverything),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NamatSpace.gutter,
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l.searchHint,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(14),
                    child: NamatIcon(
                      NamatIcons.search,
                      size: 20,
                      color: NamatColors.inkSoft,
                    ),
                  ),
                  suffixIcon: q.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(_controller.clear),
                        ),
                ),
              ),
            ),
            Expanded(
              child: q.isEmpty
                  // Not an error and not a result: the state before anyone has
                  // typed, which says what this box actually searches.
                  ? NamatEmptyState(
                      illustration: const NamatIcon(
                        NamatIcons.search,
                        size: 48,
                        color: NamatColors.inkSoft,
                      ),
                      title: l.searchStart,
                      body: l.searchStartBody,
                    )
                  : nothing
                      ? NamatEmptyState(
                          illustration: const NamatIcon(
                            NamatIcons.search,
                            size: 48,
                            color: NamatColors.inkSoft,
                          ),
                          title: l.searchNothing,
                          body: l.searchNothingBody,
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(
                            NamatSpace.gutter,
                            NamatSpace.lg,
                            NamatSpace.gutter,
                            120,
                          ),
                          children: [
                            if (partners.isNotEmpty) ...[
                              _GroupHeading(
                                label: l.searchPartnersGroup,
                                count: partners.length,
                              ),
                              for (final p in partners)
                                _PartnerHit(partner: p, arabic: arabic),
                              const SizedBox(height: NamatSpace.lg),
                            ],
                            if (services.isNotEmpty) ...[
                              _GroupHeading(
                                label: l.searchServicesGroup,
                                count: services.length,
                              ),
                              for (final (p, o) in services)
                                _ServiceHit(
                                  partner: p,
                                  offering: o,
                                  arabic: arabic,
                                ),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: NamatSpace.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: text.labelMedium)),
          Text(context.n(count), style: text.labelSmall),
        ],
      ),
    );
  }
}

class _PartnerHit extends StatelessWidget {
  const _PartnerHit({required this.partner, required this.arabic});

  final Partner partner;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: NamatSpace.sm),
      child: NamatCard(
        padding: const EdgeInsets.all(NamatSpace.md),
        onTap: () => context.go(
          '/explore/${partner.field.name}/partner/${partner.slug}',
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: partner.field.tint,
                borderRadius: BorderRadius.circular(NamatRadius.xs),
              ),
              child: NamatIcon(
                partner.field.icon,
                size: 20,
                color: partner.field.accent,
              ),
            ),
            const SizedBox(width: NamatSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.localisedName(arabic),
                    style: text.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // The field is named on every row: a result list mixing
                    // four worlds is unreadable without it.
                    '${partner.field.title(l)} · '
                    '${partner.localisedArea(arabic)}',
                    style: text.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceHit extends StatelessWidget {
  const _ServiceHit({
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

    return Padding(
      padding: const EdgeInsets.only(bottom: NamatSpace.sm),
      child: NamatCard(
        padding: const EdgeInsets.all(NamatSpace.md),
        // Lands on the partner rather than opening the sheet from here: a
        // service pulled out of its menu with no way to see the rest of it is
        // a dead end.
        onTap: () => context.go(
          '/explore/${partner.field.name}/partner/${partner.slug}',
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offering.localisedName(arabic),
                    style: text.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    partner.localisedName(arabic),
                    style: text.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: NamatSpace.sm),
            Text(
              '${context.money(offering.price)} ${l.omr}',
              style: text.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
