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
///
/// What it shows is decided by the service, not by a template. A gym class
/// leads with its level and how many places are left; a consultation with
/// whether it is in a room or over a call; a dish with its macros. One layout
/// for all three buries each one's deciding fact.
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
    final includes = o.localisedIncludes(arabic);
    final availability = o.availability;

    final covered = o.coveredByPackage && widget.partner.inPackage;
    final lineTotal = o.price * _quantity;

    // Sessions are one place each; nobody buys three seats in a class for
    // themselves. Dishes and products are the ones with a quantity.
    final countable =
        o.kind != OfferingKind.session && o.kind != OfferingKind.consultation;

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
            Text(widget.partner.localisedName(arabic), style: text.bodySmall),
            if (note != null) ...[
              const SizedBox(height: NamatSpace.md),
              Text(note, style: text.bodyMedium),
            ],

            // The quick facts, as chips — only the ones this service has. A
            // row of "unknown" chips tells the member nothing and takes the
            // space where a real answer would go.
            const SizedBox(height: NamatSpace.lg),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (o.minutes != null)
                  _Fact(
                    icon: Icons.schedule,
                    label: l.minutesShort(context.n(o.minutes!)),
                  ),
                if (o.format != null)
                  _Fact(
                    icon: _formatIcon(o.format!),
                    label: _formatLabel(o.format!, l),
                  ),
                if (o.level != null)
                  _Fact(
                    icon: Icons.signal_cellular_alt,
                    label: _levelLabel(o.level!, l),
                  ),
                if (availability?.spotsLeft != null)
                  _Fact(
                    icon: Icons.event_seat_outlined,
                    label: availability!.isFull
                        ? l.soldOut
                        : availability.isNearlyFull
                            ? l.lastSpots(context.n(availability.spotsLeft!))
                            : l.spotsLeft(context.n(availability.spotsLeft!)),
                    // The only chip that raises its voice, and only when the
                    // number is the reason to decide now rather than later.
                    urgent: availability.isFull || availability.isNearlyFull,
                  ),
              ],
            ),

            if (includes.isNotEmpty) ...[
              const SizedBox(height: NamatSpace.xl),
              Text(l.whatsIncluded, style: text.labelMedium),
              const SizedBox(height: NamatSpace.sm),
              for (final line in includes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Icon(
                          Icons.check,
                          size: 15,
                          color: NamatColors.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(line, style: text.bodySmall)),
                    ],
                  ),
                ),
            ],

            if (availability != null && availability.times.isNotEmpty) ...[
              const SizedBox(height: NamatSpace.xl),
              Text(l.nextTimes, style: text.labelMedium),
              const SizedBox(height: NamatSpace.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t
                      in availability.upcoming(DateTime.now(), count: 4))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: NamatColors.surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: NamatColors.line),
                      ),
                      child: Text(context.dateTime(t), style: text.labelSmall),
                    ),
                ],
              ),
            ] else if (o.kind.needsSlot) ...[
              const SizedBox(height: NamatSpace.xl),
              Text(l.noFixedTimes, style: text.labelSmall),
            ],

            // Only where nutrition is a sensible thing to ask about. A gym
            // class with "no figures supplied" underneath reads as missing
            // data rather than as a category that never had any.
            if (o.nutrition != null || field == NamatField.meals) ...[
              const SizedBox(height: NamatSpace.xl),
              _NutritionBlock(nutrition: o.nutrition, accent: field.accent),
              const SizedBox(height: NamatSpace.sm),
              // Said out loud rather than left blank. Someone with a nut
              // allergy needs to know the app does not know, rather than read
              // silence as safe.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.info_outline,
                      size: 14,
                      color: NamatColors.inkSoft,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(l.allergensUnknown, style: text.labelSmall),
                  ),
                ],
              ),
            ],

            if (o.kind.needsSlot || o.kind == OfferingKind.pass) ...[
              const SizedBox(height: NamatSpace.xl),
              Text(l.cancellationTitle, style: text.labelMedium),
              const SizedBox(height: NamatSpace.xs),
              Text(
                o.cancellation == null
                    ? l.cancelUnknown
                    : _cancelLabel(o.cancellation!, l),
                style: text.bodySmall,
              ),
            ],

            if (countable) ...[
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
            ],

            const SizedBox(height: NamatSpace.xl),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${context.money(lineTotal)} ${l.omr}',
                  style: text.titleMedium?.copyWith(
                    color: covered ? NamatColors.inkSoft : NamatColors.ink,
                    decoration: covered ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (covered)
                  Text(
                    l.freeFromPackage,
                    style:
                        text.labelMedium?.copyWith(color: NamatColors.accent),
                  ),
              ],
            ),
            const SizedBox(height: NamatSpace.lg),

            if (!o.canBuy) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(NamatSpace.lg),
                decoration: BoxDecoration(
                  color: NamatColors.warmSoft,
                  borderRadius: BorderRadius.circular(NamatRadius.sm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.isSoldOut ? l.soldOut : l.outOfStock,
                      style: text.labelMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(l.soldOutBody, style: text.labelSmall),
                  ],
                ),
              ),
              const SizedBox(height: NamatSpace.sm),
            ],

            FilledButton(
              // Disabled rather than hidden. A member who came for this class
              // needs to see that it exists and is full, not to wonder
              // whether they misremembered the app.
              onPressed: o.canBuy
                  ? () {
                      ref
                          .read(cartProvider.notifier)
                          .add(o, quantity: countable ? _quantity : 1);
                      Navigator.of(context).pop();
                      // No action button on it. The partner page grows a
                      // persistent "view cart" bar the moment the cart stops
                      // being empty, so a second route inside a four-second
                      // snackbar buys nothing — and the two together overflow
                      // the bar at 360dp.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.addedToCart),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
              child: Text(o.canBuy ? l.addToCart : l.soldOut),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatLabel(ServiceFormat f, L l) => switch (f) {
        ServiceFormat.inPerson => l.formatInPerson,
        ServiceFormat.remote => l.formatRemote,
        ServiceFormat.either => l.formatEither,
      };

  static IconData _formatIcon(ServiceFormat f) => switch (f) {
        ServiceFormat.inPerson => Icons.place_outlined,
        ServiceFormat.remote => Icons.videocam_outlined,
        ServiceFormat.either => Icons.swap_horiz,
      };

  static String _levelLabel(FitnessLevel v, L l) => switch (v) {
        FitnessLevel.any => l.levelAny,
        FitnessLevel.beginner => l.levelBeginner,
        FitnessLevel.intermediate => l.levelIntermediate,
        FitnessLevel.advanced => l.levelAdvanced,
      };

  static String _cancelLabel(CancellationPolicy c, L l) => switch (c) {
        CancellationPolicy.free24h => l.cancelFree24h,
        CancellationPolicy.free2h => l.cancelFree2h,
        CancellationPolicy.nonRefundable => l.cancelNonRefundable,
      };
}

/// One quick fact, as a chip.
class _Fact extends StatelessWidget {
  const _Fact({
    required this.icon,
    required this.label,
    this.urgent = false,
  });

  final IconData icon;
  final String label;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colour = urgent ? NamatColors.danger : NamatColors.inkSoft;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: urgent ? NamatColors.surface : NamatColors.warmSoft,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: urgent ? NamatColors.danger : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colour),
          const SizedBox(width: 5),
          Text(label, style: text.labelSmall?.copyWith(color: colour)),
        ],
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
              Text(value, style: text.titleMedium?.copyWith(color: accent)),
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
              color:
                  onTap == null ? NamatColors.warmSoft : NamatColors.greenSoft,
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
