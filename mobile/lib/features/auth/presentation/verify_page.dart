import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../account/domain/session.dart';
import '../domain/accounts.dart';
import '../domain/profile_draft.dart';

/// Code entry.
///
/// No SMS provider is connected, so the code is shown on screen. That is a
/// development affordance and it is labelled as one — the alternative, a
/// silently-accepted empty field, would hide the fact that verification does
/// not really happen yet.
class VerifyPage extends ConsumerStatefulWidget {
  const VerifyPage({super.key, required this.mode});

  final String mode;

  @override
  ConsumerState<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends ConsumerState<VerifyPage> {
  static const _demoCode = '123456';

  final _controller = TextEditingController();
  final _focus = FocusNode();
  String? _error;
  int _cooldown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _check(String value) {
    if (value.length < 6) return;
    if (value != _demoCode) {
      setState(() {
        _error = L.of(context)!.wrongCode;
        _controller.clear();
      });
      return;
    }
    // The session starts here, not on the setup screen: a member who skips
    // every question is still signed in, and gating on the answers would
    // leave them a guest who cannot order.
    final draft = ref.read(profileDraftProvider);
    ref.read(sessionProvider.notifier).signIn(name: draft.name);

    // And the number is on the books from this point, so a second sign-up
    // with it is offered the sign-in door instead of the questions again.
    ref.read(accountsProvider.notifier).register(draft.phone);

    // Signing up continues into the questions; signing in already has answers.
    context.go(widget.mode == 'signup' ? '/setup' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final phone = ref.watch(profileDraftProvider).phone;

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: NamatBack(fallback: '/${widget.mode}'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NamatSpace.gutter,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: revealAll([
                Text(l.verifyTitle, style: text.displayMedium),
                const SizedBox(height: NamatSpace.sm),
                // The number is read here, so its digits follow the locale —
                // unlike the field above, which is typed.
                Text(
                  l.verifyBody(context.phone(phone)),
                  style: text.bodySmall,
                ),
                TextButton(
                  onPressed: () => context.go('/${widget.mode}'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text(l.editNumber),
                ),
                const SizedBox(height: NamatSpace.xl),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    // The code is transcribed from a message into a keypad, so
                    // it stays Latin regardless of the interface language.
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: text.displayMedium?.copyWith(letterSpacing: 12),
                    onChanged: (v) {
                      if (_error != null) setState(() => _error = null);
                      _check(v);
                    },
                    decoration: const InputDecoration(hintText: '······'),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: NamatSpace.sm),
                  Text(
                    _error!,
                    style: text.bodySmall?.copyWith(color: NamatColors.danger),
                  ),
                ],
                const SizedBox(height: NamatSpace.lg),
                // Labelled as a demo affordance rather than presented as if a
                // message had actually been sent.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(NamatSpace.md),
                  decoration: BoxDecoration(
                    color: NamatColors.warmSoft,
                    borderRadius: BorderRadius.circular(NamatRadius.sm),
                  ),
                  child: Text(
                    '${l.demoCode}: $_demoCode',
                    textAlign: TextAlign.center,
                    style: text.labelMedium,
                  ),
                ),
                const SizedBox(height: NamatSpace.xl),
                FilledButton(
                  onPressed: () => _check(_controller.text),
                  child: Text(l.verifyCta),
                ),
                const SizedBox(height: NamatSpace.sm),
                Center(
                  child: TextButton(
                    onPressed: _cooldown > 0
                        ? null
                        : () => setState(() {
                              _cooldown = 30;
                              _tick();
                            }),
                    child: Text(
                      _cooldown > 0
                          ? l.resendIn(context.n(_cooldown))
                          : l.resend,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
