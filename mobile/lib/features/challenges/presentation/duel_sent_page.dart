import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/home_page.dart' show NamatAvatar;

/// Confirmation that the invitation went.
///
/// The pulse travels from you to them and stops — it does not loop. A looping
/// animation on a confirmation screen reads as "still sending"; one pass reads
/// as "sent", which is what happened.
class DuelSentPage extends StatefulWidget {
  const DuelSentPage({super.key, required this.username});

  final String username;

  @override
  State<DuelSentPage> createState() => _DuelSentPageState();
}

class _DuelSentPageState extends State<DuelSentPage>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(NamatSpace.gutter),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) => SizedBox(
                    height: 96,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const NamatAvatar(name: 'سارة', size: 58),
                        SizedBox(
                          width: 96,
                          child: CustomPaint(
                            painter: _PulsePainter(_c.value),
                            size: const Size(96, 58),
                          ),
                        ),
                        Opacity(
                          // The opponent fades in as the pulse reaches them.
                          opacity: Curves.easeOut.transform(
                            (_c.value * 1.6 - 0.6).clamp(0.0, 1.0),
                          ),
                          child: NamatAvatar(
                            name: widget.username,
                            size: 58,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: NamatSpace.xxl),
                Text(
                  l.challengeSent,
                  style: text.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: NamatSpace.sm),
                Text(
                  l.challengeSentBody,
                  style: text.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: NamatSpace.section),
                FilledButton(
                  onPressed: () => context.go('/challenges'),
                  child: Text(l.backToChallenges),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter(this.t);

  /// 0–1 along the journey.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;

    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = NamatColors.line
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    if (t <= 0) return;

    // A short bright segment travelling the line, rather than a dot: a moving
    // dash reads as energy where a dot reads as loading.
    final head = (t * size.width).clamp(0.0, size.width);
    final tail = (head - 26).clamp(0.0, size.width);

    canvas.drawLine(
      Offset(tail, y),
      Offset(head, y),
      Paint()
        ..color = NamatColors.accent
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.t != t;
}
