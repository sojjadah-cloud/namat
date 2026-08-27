import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../core/l10n/numbers.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/field.dart';

/// One field: search and filters scoped to it.
///
/// Search only exists here, never on the page before — and it only ever
/// queries this field, so "بروتين" inside meals finds kitchens and the same
/// word inside stores finds supplements, with no way for an unrelated result
/// to appear.
class FieldPage extends StatefulWidget {
  const FieldPage({super.key, required this.fieldKey});

  final String fieldKey;

  @override
  State<FieldPage> createState() => _FieldPageState();
}

typedef _Result = (String name, String meta, double km, bool inPackage);

class _FieldPageState extends State<FieldPage> {
  final _search = TextEditingController();
  final _active = <String>{};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Stand-in results until the API is wired. Two fields are genuinely empty
  /// in the real catalogue, and that is represented rather than papered over.
  static const Map<NamatField, List<_Result>> _sample = {
    NamatField.meals: [
      ('مطعم المعمل الصحي', 'عالي البروتين واشتراكات · الغبرة الشمالية', 0.3, true),
      ('Nourish Kitchen', 'اشتراكات ووجبات صحية · شارع العلم', 4.5, true),
      ('مطبخ هيلدا كيتو', 'كيتو وقليل الكربوهيدرات · الخوير', 4.7, false),
      ('Macro Boost', 'عالي البروتين واشتراكات · الخوير', 5.0, false),
    ],
    NamatField.stores: [
      ('Tree of Life', 'منتجات صحية · غلا', 6.2, false),
      ('Nefisorganic', 'منتجات عضوية · مسقط', 8.1, false),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final field = NamatField.byKey(widget.fieldKey);

    if (field == null) {
      return Scaffold(
        appBar: AppBar(),
        body: NamatEmptyState(title: l.errorTitle, body: l.errorBody),
      );
    }

    final results = _sample[field] ?? const <_Result>[];

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/use'),
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
              Text(field.title(l)),
            ],
          ),
        ),
        body: results.isEmpty
            // A search box above an empty list looks broken rather than empty,
            // so it is not rendered at all in this state.
            ? NamatEmptyState(
                illustration: NamatIcon(
                  field.icon,
                  size: 56,
                  color: NamatColors.inkSoft,
                ),
                title: l.noPartnersYet,
                body: l.useSub,
                action: FilledButton(
                  onPressed: () => context.go('/use'),
                  child: Text(l.useNamatCta),
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
                  Text(l.resultCount(context.n(results.length)), style: text.bodySmall),
                  const SizedBox(height: NamatSpace.md),
                  for (final r in results) ...[
                    _ResultCard(result: r, field: field, fieldKey: widget.fieldKey),
                    const SizedBox(height: NamatSpace.md),
                  ],
                ],
              ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.field,
    required this.fieldKey,
  });

  final _Result result;
  final NamatField field;
  final String fieldKey;

  /// Initials stand in for a logo. A partner's trademark is theirs to give,
  /// and a stock photo pretending to be their shopfront is a false claim.
  String get _monogram {
    final words = result.$1.split(' ').where((w) => w.length > 1).toList();
    if (words.isEmpty) return '؟';
    final first = words.first;
    final isArabic = RegExp(r'[؀-ۿ]').hasMatch(first);
    if (isArabic) {
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

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final (name, meta, km, inPackage) = result;

    return NamatCard(
      padding: const EdgeInsets.all(NamatSpace.md),
      onTap: () => context.go('/use/$fieldKey/partner/${_slug(name)}'),
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
              _monogram,
              style: text.titleLarge?.copyWith(color: field.accent),
            ),
          ),
          const SizedBox(width: NamatSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: text.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: text.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                    Text('${context.n(km)} كم', style: text.labelSmall),
                    if (inPackage) ...[
                      const SizedBox(width: 10),
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Until the API supplies real identifiers, the slug is derived from the name
/// so a tap still lands on the right partner.
String _slug(String name) => switch (name) {
      'مطعم المعمل الصحي' => 'healthy-lab',
      'Nourish Kitchen' => 'nourish-kitchen',
      _ => 'healthy-lab',
    };
