import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';

/// Packages, as cards you move through rather than a pricing table.
///
/// A table invites comparison by number, which is the wrong question — the
/// three differ by who they suit, not by how much they cost. One card at a
/// time, each with its own colour and its own growing mark, asks the reader
/// which one sounds like them.
class PackagesPage extends StatefulWidget {
  const PackagesPage({super.key});

  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  int _index = 1;

  static const _packages = [
    (
      name: 'نشِط',
      bestFor: 'لمن يتدرّب ويريد للغذاء أن يواكبه',
      price: 39,
      icon: NamatIcons.fitness,
      accent: NamatColors.fitness,
      tint: NamatColors.fitnessSoft,
      benefits: [
        '٨ جلسات نادٍ أو حصص شهرياً',
        '٤ جلسات لياقة في الهواء الطلق',
        'جلستا استشفاء',
      ],
      current: false,
    ),
    (
      name: 'توازن',
      bestFor: 'لمن يبني عادات أفضل، أسبوعاً بعد أسبوع',
      price: 55,
      icon: NamatIcons.leaf,
      accent: NamatColors.accent,
      tint: NamatColors.greenSoft,
      benefits: [
        '١٢ وجبة من مطابخ الشركاء',
        '٤ جلسات لياقة وحصتا بيلاتس',
        'استشارة تغذية واحدة',
      ],
      current: true,
    ),
    (
      name: 'متكامل',
      bestFor: 'لمن يريد المنظومة كاملة، دون حساب',
      price: 89,
      icon: NamatIcons.reward,
      accent: NamatColors.products,
      tint: NamatColors.productsSoft,
      benefits: [
        '٢٠ وجبة من مطابخ الشركاء',
        '١٢ جلسة نادٍ شهرياً',
        'استشارتا تغذية مع متابعة',
      ],
      current: false,
    ),
  ];

  /// Opens on the middle card so both neighbours are visible, and the reader
  /// can see there is a choice without scrolling to discover it.
  late final PageController _controller =
      PageController(viewportFraction: 0.86, initialPage: 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/journey'),
            icon: const Icon(Icons.arrow_forward),
          ),
          title: Text(l.packagesTitle),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NamatSpace.gutter,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l.packagesSub, style: text.bodySmall),
              ),
            ),
            const SizedBox(height: NamatSpace.xl),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _packages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = _packages[i];
                  return AnimatedScale(
                    // The focused card sits slightly forward, so the eye knows
                    // which one it is reading.
                    scale: i == _index ? 1 : 0.94,
                    duration: NamatMotion.base,
                    curve: NamatMotion.enter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _PackageCard(
                        name: p.name,
                        bestFor: p.bestFor,
                        price: p.price,
                        icon: p.icon,
                        accent: p.accent,
                        tint: p.tint,
                        benefits: p.benefits,
                        current: p.current,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: NamatSpace.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _packages.length; i++)
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
            const SizedBox(height: NamatSpace.section),
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.name,
    required this.bestFor,
    required this.price,
    required this.icon,
    required this.accent,
    required this.tint,
    required this.benefits,
    required this.current,
  });

  final String name;
  final String bestFor;
  final int price;
  final NamatIcons icon;
  final Color accent;
  final Color tint;
  final List<String> benefits;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return NamatCard(
      organic: true,
      color: tint,
      padding: const EdgeInsets.all(NamatSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NamatIcon(icon, size: 34, color: accent),
              const Spacer(),
              if (current)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: NamatColors.surface,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    l.currentPackage,
                    style: text.labelSmall?.copyWith(color: accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: NamatSpace.xl),
          Text(name, style: text.displayMedium),
          const SizedBox(height: 4),
          Text(bestFor, style: text.bodySmall),
          const SizedBox(height: NamatSpace.xl),
          for (final b in benefits)
            Padding(
              padding: const EdgeInsets.only(bottom: NamatSpace.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: NamatSpace.sm),
                  Expanded(child: Text(b, style: text.bodyMedium)),
                ],
              ),
            ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(context.n(price), style: text.displayLarge),
              const SizedBox(width: 6),
              Text('ر.ع · ${l.perMonth}', style: text.bodySmall),
            ],
          ),
          const SizedBox(height: NamatSpace.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: current ? null : () {},
              style: FilledButton.styleFrom(backgroundColor: accent),
              child: Text(current ? l.currentPackage : l.choosePackage),
            ),
          ),
        ],
      ),
    );
  }
}
