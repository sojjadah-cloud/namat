import 'package:flutter/material.dart';

import '../theme/namat_colors.dart';
import '../widgets/namat_icon.dart';
import '../widgets/namat_scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Loading and failure, as designed states rather than as afterthoughts.
///
/// A spinner in the middle of an empty screen tells a member that something is
/// happening and nothing about what. A skeleton tells them what is coming and
/// how much of it, so the page does not jump when it arrives — which is the
/// part people actually notice.

/// A single shimmering placeholder block.
class NamatSkeleton extends StatefulWidget {
  const NamatSkeleton({
    super.key,
    this.height = 16,
    this.width,
    this.radius = 8,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  State<NamatSkeleton> createState() => _NamatSkeletonState();
}

class _NamatSkeletonState extends State<NamatSkeleton>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          // A shift in opacity rather than a sweeping gradient: the sweep
          // draws the eye across the screen repeatedly, which is exactly the
          // wrong thing to do while somebody is waiting.
          color: Color.lerp(
            NamatColors.line,
            NamatColors.warmSoft,
            _c.value,
          ),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// The shape of a list of partner cards, before the partners arrive.
class NamatListSkeleton extends StatelessWidget {
  const NamatListSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        NamatSpace.gutter,
        NamatSpace.lg,
        NamatSpace.gutter,
        120,
      ),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: NamatSpace.md),
      itemBuilder: (_, __) => const NamatCard(
        padding: EdgeInsets.all(NamatSpace.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NamatSkeleton(height: 62, width: 62, radius: NamatRadius.xs),
            SizedBox(width: NamatSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NamatSkeleton(height: 15, width: 150),
                  SizedBox(height: 8),
                  NamatSkeleton(height: 12, width: 210),
                  SizedBox(height: 8),
                  NamatSkeleton(height: 12, width: 90),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Which failure this is.
///
/// Separate cases rather than one "something went wrong", because the member's
/// next move differs: turn the wifi on, try another card, pick another time.
/// A single generic message makes all three look like the app's fault and
/// leaves the member with nothing to do.
enum NamatFailure { offline, payment, unavailable, server }

class NamatErrorState extends StatelessWidget {
  const NamatErrorState({
    super.key,
    required this.failure,
    this.onRetry,
    this.retryLabel,
  });

  final NamatFailure failure;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;

    final (title, body, icon) = switch (failure) {
      NamatFailure.offline => (l.offlineTitle, l.offlineBody, Icons.wifi_off),
      NamatFailure.payment => (
          l.paymentFailed,
          l.paymentFailedBody,
          Icons.credit_card_off,
        ),
      NamatFailure.unavailable => (
          l.unavailableTitle,
          l.unavailableBody,
          Icons.event_busy,
        ),
      NamatFailure.server => (
          l.errorTitle,
          l.errorBody,
          Icons.cloud_off,
        ),
    };

    return NamatEmptyState(
      illustration: Icon(icon, size: 48, color: NamatColors.inkSoft),
      title: title,
      body: body,
      action: onRetry == null
          ? null
          : FilledButton(
              onPressed: onRetry,
              child: Text(retryLabel ?? l.retry),
            ),
    );
  }
}

/// The prompt a guest meets at the point of committing to something.
///
/// Shown at the action, never at the door. A marketplace that asks for a phone
/// number before it will show a menu loses the people who have not decided
/// yet; asking at the moment of booking is simply what booking requires.
class NamatSignInPrompt extends StatelessWidget {
  const NamatSignInPrompt({
    super.key,
    required this.title,
    required this.onSignIn,
    required this.onDismiss,
  });

  final String title;
  final VoidCallback onSignIn;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NamatSpace.gutter,
        NamatSpace.xl,
        NamatSpace.gutter,
        NamatSpace.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NamatIcon(
            NamatIcons.leaf,
            size: 30,
            color: NamatColors.accent,
            filled: true,
          ),
          const SizedBox(height: NamatSpace.md),
          Text(title, style: text.titleLarge),
          const SizedBox(height: NamatSpace.xs),
          Text(l.signInBody, style: text.bodySmall),
          const SizedBox(height: NamatSpace.xl),
          FilledButton(onPressed: onSignIn, child: Text(l.login)),
          const SizedBox(height: NamatSpace.xs),
          // Dismissing returns the member exactly where they were, with what
          // they were looking at still on screen behind this sheet.
          TextButton(onPressed: onDismiss, child: Text(l.keepBrowsing)),
        ],
      ),
    );
  }
}
