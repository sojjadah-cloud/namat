import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../l10n/app_localizations.dart';
import '../../bookings/domain/cart_notifier.dart';
import '../../use/domain/field.dart';
import '../domain/catalogue.dart';

/// The detail sheet for one buyable thing.
///
/// A sheet rather than a page: choosing a dish is a decision made against the
/// rest of the menu, and pushing a full screen makes the member lose their
/// place in a list they were still comparing.
Future<void> showOfferingSheet(
  BuildContext context, {
  required Offering offering,
  required Partner partner,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // The root navigator, not the tab's own. Pushed onto the branch navigator
    // the sheet renders inside the shell, and the bottom navigation bar sits
    // on top of exactly the strip where the add button is — so the button is
    // visible, reachable by a finder, and impossible to tap.
    useRootNavigator: true,
    builder: (_) => _OfferingSheet(offering: offering, partner: partner),
  );
}

class _OfferingSheet extends ConsumerStatefulWidget {
  const _OfferingSheet({required this.offering, required this.partner});

  final Offering offering;
  final Partner partner;

  @override
  ConsumerState<_OfferingSheet> createState() => _OfferingSheetState();
}

class _OfferingSheetState extends ConsumerState<_OfferingSheet> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final o = widget.offering;
    final field = widget.partner.field;
    final note = o.localisedNote(arabic);

    final covered = o.coveredByPackage && widget.partner.inPackage;
    final lineTotal = o.price * _quantity;

    return Container(
      decoration: const BoxDecoration(
        color: NamatColors.canvas,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NamatRadius.organic),
        ),
      ),
      padding: EdgeInsets.only(
        left: NamatSpace.gutter,
        right: NamatSpace.gutter,
        top: NamatSpace.md,
        // Clears the keyboard and the home indicator both.
        bottom: MediaQuery.of(context).viewInsets.bottom + NamatSpace.xxl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: NamatColors.line,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: NamatSpace.xl),
            Text(o.localisedName(arabic), style: text.titleLarge),
            const SizedBox(height: NamatSpace.xs),
            Text(
              widget.partner.localisedName(arabic),
              style: text.bodySmall,
            ),
            if (note != null) ...[
              const SizedBox(height: NamatSpace.md),
              Text(note, style: text.bodyMedium),
            ],
            if (o.minutes != null) ...[
              const SizedBox(height: NamatSpace.md),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 15,
                    color: NamatColors.inkSoft,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l.minutesShort(context.n(o.minutes!)),
                    style: text.labelSmall,
                  ),
                ],
              ),
            ],
            // Only where nutrition is a sensible thing to ask about. A gym
            // class with "no figures supplied" underneath reads as missing
            // data rather than as a category that never had any.
            if (o.nutrition != null || field == NamatField.meals) ...[
              const SizedBox(height: NamatSpace.xl),
              _NutritionBlock(nutrition: o.nutrition, accent: field.accent),
            ],
            const SizedBox(height: NamatSpace.xl),
            Row(
              children: [
                Text(l.quantity, style: text.labelMedium),
                const Spacer(),
                _Stepper(
                  value: _quantity,
                  onChanged: (v) => setState(() => _quantity = v),
                ),
              ],
            ),
            const SizedBox(height: NamatSpace.xl),
            Row(
              children: [
                Text(
                  '${context.money(lineTotal)} ${l.omr}',
                  style: text.titleMedium?.copyWith(
                    color: covered ? NamatColors.inkSoft : NamatColors.ink,
                    decoration:
                        covered ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (covered) ...[
                  const SizedBox(width: NamatSpace.sm),
                  Text(
                    l.freeFromPackage,
                    style: text.labelMedium
                        ?.copyWith(color: NamatColors.accent),
                  ),
                ],
              ],
            ),
            const SizedBox(height: NamatSpace.lg),
            FilledButton(
              onPressed: () {
                ref
                    .read(cartProvider.notifier)
                    .add(o, quantity: _quantity);
                Navigator.of(context).pop();
                // No action button on it. The partner page grows a persistent
                // "view cart" bar the moment the cart stops being empty, so a
                // second route in a four-second snackbar buys nothing — and
                // the two of them together overflow the bar at 360dp.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.addedToCart),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(l.addToCart),
            ),
          ],
        ),
      ),
    );
  }

}

class _NutritionBlock extends StatelessWidget {
  const _NutritionBlock({required this.nutrition, required this.accent});

  final Nutrition? nutrition;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final n = nutrition;

    // Absent figures are stated as absent. Rendering zeroes would tell a
    // member counting protein that this dish has none of it.
    if (n == null) {
      return Text(l.nutritionUnknown, style: text.labelSmall);
    }

    Widget cell(String label, String value) => Expanded(
          child: Column(
            children: [
              Text(
                value,
                style: text.titleMedium?.copyWith(color: accent),
              ),
              const SizedBox(height: 2),
              Text(label, style: text.labelSmall),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: NamatSpace.lg),
      decoration: BoxDecoration(
        color: NamatColors.surface,
        borderRadius: BorderRadius.circular(NamatRadius.sm),
        border: Border.all(color: NamatColors.line),
      ),
      child: Column(
        children: [
          Text(l.perServing, style: text.labelSmall),
          const SizedBox(height: NamatSpace.md),
          Row(
            children: [
              cell(l.calories, context.n(n.calories)),
              cell(l.protein, l.gramsShort(context.n(n.protein))),
              cell(l.carbs, l.gramsShort(context.n(n.carbs))),
              cell(l.fat, l.gramsShort(context.n(n.fat))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget button(IconData icon, VoidCallback? onTap) => Pressable(
          onTap: onTap ?? () {},
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: onTap == null
                  ? NamatColors.warmSoft
                  : NamatColors.greenSoft,
              borderRadius: BorderRadius.circular(NamatRadius.xs),
            ),
            child: Icon(
              icon,
              size: 18,
              color: onTap == null ? NamatColors.line : NamatColors.deep,
            ),
          ),
        );

    return Row(
      children: [
        // One is the floor: removing the last one is what the cart's own
        // remove control is for, and a zero-quantity line is not a thing.
        button(Icons.remove, value > 1 ? () => onChanged(value - 1) : null),
        SizedBox(
          width: 48,
          child: Text(
            context.n(value),
            textAlign: TextAlign.center,
            style: text.titleMedium,
          ),
        ),
        button(Icons.add, value < 20 ? () => onChanged(value + 1) : null),
      ],
    );
  }
}
