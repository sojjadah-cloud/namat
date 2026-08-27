import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../use/domain/field.dart';

/// A partner.
///
/// Built to stay presentable when a business has given us nothing but a name.
/// Most partners in the Muscat catalogue have no photograph, no description
/// and no ratings — a page that needs those to look finished would look broken
/// for most of the list, so the header is a monogram on the field's own colour
/// and absent facts are simply absent rather than shown as zero.
typedef _Partner = ({
  String name,
  String area,
  NamatField field,
  double? rating,
  double? fromPrice,
  double distanceKm,
  bool inPackage,
  List<String> tags,
  List<String> services,
});

class PartnerPage extends StatelessWidget {
  const PartnerPage({super.key, required this.slug});

  final String slug;

  /// Stand-in until the API exists. `rating` and `fromPrice` are null on
  /// purpose for partners whose research never established them — the type is
  /// written out because inference would otherwise read "always null" from the
  /// sample and make the populated branch dead code.
  static const Map<String, _Partner> _partners = {
    'healthy-lab': (
      name: 'مطعم المعمل الصحي',
      area: 'الغبرة الشمالية',
      field: NamatField.meals,
      rating: null,
      fromPrice: null,
      distanceKm: 0.3,
      inPackage: true,
      tags: ['عالي البروتين', 'اشتراكات', 'وجبات صحية'],
      services: ['وجبة غداء متوازنة', 'اشتراك أسبوعي', 'اشتراك شهري'],
    ),
    'nourish-kitchen': (
      name: 'Nourish Kitchen',
      area: 'شارع العلم',
      field: NamatField.meals,
      rating: null,
      fromPrice: null,
      distanceKm: 4.5,
      inPackage: true,
      tags: ['اشتراكات', 'وجبات صحية'],
      services: ['خطة وجبات أسبوعية', 'وجبة يومية'],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final p = _partners[slug] ?? _partners['healthy-lab']!;
    final field = p.field;

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_forward),
          ),
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
                Container(
                  width: 76,
                  height: 76,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: field.tint,
                    borderRadius: BorderRadius.circular(NamatRadius.sm),
                  ),
                  child: Text(
                    _monogram(p.name),
                    style: text.displayMedium?.copyWith(color: field.accent),
                  ),
                ),
                const SizedBox(width: NamatSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: text.titleLarge),
                      const SizedBox(height: 2),
                      Text(field.title(l), style: text.bodySmall),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const NamatIcon(
                            NamatIcons.location,
                            size: 14,
                            color: NamatColors.inkSoft,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${p.area} · ${context.n(p.distanceKm)} كم',
                            style: text.labelSmall,
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
            Row(
              children: [
                if (p.rating == null)
                  Text(l.partnerNoRating, style: text.labelSmall)
                else
                  Text(context.n(p.rating!), style: text.labelMedium),
                if (p.inPackage) ...[
                  const Spacer(),
                  Row(
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
              ],
            ),
            const SizedBox(height: NamatSpace.xl),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in p.tags)
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
            const SizedBox(height: NamatSpace.xxl),
            Text(l.partnerAbout, style: text.labelMedium),
            const SizedBox(height: NamatSpace.sm),
            Text(l.noDescription, style: text.bodySmall),
            const SizedBox(height: NamatSpace.xxl),
            Text(l.partnerServices, style: text.labelMedium),
            const SizedBox(height: NamatSpace.md),
            for (final s in p.services)
              Padding(
                padding: const EdgeInsets.only(bottom: NamatSpace.sm),
                child: NamatCard(
                  padding: const EdgeInsets.all(NamatSpace.lg),
                  onTap: () {},
                  child: Row(
                    children: [
                      Expanded(child: Text(s, style: text.bodyMedium)),
                      const Icon(
                        Icons.chevron_left,
                        color: NamatColors.inkSoft,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
          ]),
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.md,
            NamatSpace.gutter,
            NamatSpace.xxl,
          ),
          child: FilledButton(
            onPressed: () {},
            // Members with a package spend an allowance rather than paying
            // again, and the button says which one is about to happen.
            child: Text(p.inPackage ? l.useFromPackage : l.bookNow),
          ),
        ),
      ),
    );
  }

  /// Initials stand in for a logo, which belongs to the partner to give.
  static String _monogram(String name) {
    final words = name.split(' ').where((w) => w.length > 1).toList();
    if (words.isEmpty) return '؟';
    final first = words.first;
    if (RegExp(r'[؀-ۿ]').hasMatch(first)) {
      // Skip the definite article, or every "الـ" name yields the same alef.
      final stem =
          first.startsWith('ال') && first.length > 3 ? first.substring(2) : first;
      return stem.substring(0, 1);
    }
    return words.length > 1
        ? (first[0] + words[1][0]).toUpperCase()
        : first.substring(0, 2).toUpperCase();
  }
}
