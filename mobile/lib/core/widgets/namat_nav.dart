import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/namat_colors.dart';

/// Going back, and going deeper.
///
/// Both of these were wrong in Arabic, in the same way and for the same
/// reason. Flutter already mirrors directional icons in RTL — `arrow_back`,
/// `arrow_forward`, `chevron_left` and `chevron_right` all carry
/// `matchTextDirection: true` — so reaching for the opposite-facing icon to
/// "fix" the direction by hand mirrors it a second time and lands back where
/// it started. The app used `arrow_forward` for back, which rendered pointing
/// left in Arabic when back is to the right; and `chevron_left` to mean
/// "onward", which rendered pointing right when onward is to the left.
///
/// The rule, once and in one place: name the icon for what it means in LTR and
/// let the framework mirror it. `arrow_back` is always back. `chevron_right`
/// is always onward.

/// The back affordance, in every app bar.
///
/// Popping rather than navigating, so a screen returns to whatever opened it
/// instead of to whatever the author guessed. The fallback only applies when
/// there is genuinely nothing to pop — a deep link opened cold, or a tab root.
class NamatBack extends StatelessWidget {
  const NamatBack({super.key, this.fallback});

  /// Where to go when the stack is empty. Null means the app decides — which
  /// for a tab root means there is nothing to go back to, and the button is
  /// not shown at all.
  final String? fallback;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    if (!canPop && fallback == null) return const SizedBox.shrink();

    return IconButton(
      // Mirrored by the framework: right-pointing in Arabic, left in English.
      icon: const Icon(Icons.arrow_back),
      onPressed: () =>
          canPop ? context.pop() : context.go(fallback!),
    );
  }
}

/// The "there is more this way" chevron on a row.
///
/// Points along the reading direction — left in Arabic, right in English —
/// because it indicates travel, not a fixed side of the screen.
class NamatChevron extends StatelessWidget {
  const NamatChevron({super.key, this.size = 18, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right,
      size: size,
      color: color ?? NamatColors.inkSoft,
    );
  }
}
