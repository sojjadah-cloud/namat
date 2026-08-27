import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/profile_draft.dart';

/// Phone entry — the whole of signing up and signing in.
///
/// There is no password anywhere in NAMAT. Proving the number is the account,
/// so the same screen serves both cases and the only difference is the copy
/// and where it goes afterwards.
class PhonePage extends ConsumerStatefulWidget {
  const PhonePage({super.key, required this.mode});

  /// `signup` or `login`. Only the wording and the destination differ.
  final String mode;

  @override
  ConsumerState<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends ConsumerState<PhonePage> {
  final _controller = TextEditingController();
  String? _error;

  bool get _isSignup => widget.mode == 'signup';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text;
    if (!isValidPhone(raw)) {
      setState(() => _error = L.of(context)!.invalidPhone);
      return;
    }
    ref.read(profileDraftProvider.notifier).setPhone(normalisePhone(raw));
    context.go('/${widget.mode}/verify');
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
            onPressed: () => context.go('/welcome'),
            icon: const Icon(Icons.arrow_forward),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NamatSpace.gutter,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: revealAll([
                const NamatLogoMark(size: 40),
                const SizedBox(height: NamatSpace.xl),
                Text(
                  _isSignup ? l.signupTitle : l.loginTitle,
                  style: text.displayMedium,
                ),
                const SizedBox(height: NamatSpace.sm),
                Text(
                  _isSignup ? l.signupBody : l.loginBody,
                  style: text.bodySmall,
                ),
                const SizedBox(height: NamatSpace.section),
                Text(l.phoneLabel, style: text.labelMedium),
                const SizedBox(height: NamatSpace.sm),
                // Pinned LTR: a phone number is dialled, not read, and bidi
                // reordering would put the country code at the wrong end.
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      Container(
                        height: 56,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: NamatColors.warmSoft,
                          borderRadius:
                              BorderRadius.circular(NamatRadius.sm),
                          border: Border.all(color: NamatColors.line),
                        ),
                        child: Text('+968', style: text.labelMedium),
                      ),
                      const SizedBox(width: NamatSpace.sm),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          keyboardType: TextInputType.phone,
                          // Latin digits only: this is typed on a keypad and
                          // sent to a network, not read as prose.
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                          ],
                          onChanged: (_) {
                            if (_error != null) setState(() => _error = null);
                          },
                          onSubmitted: (_) => _submit(),
                          decoration: InputDecoration(hintText: l.phoneHint),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: NamatSpace.sm),
                  Text(
                    _error!,
                    style: text.bodySmall?.copyWith(color: NamatColors.danger),
                  ),
                ],
                const SizedBox(height: NamatSpace.xl),
                FilledButton(onPressed: _submit, child: Text(l.continueCta)),
                const SizedBox(height: NamatSpace.lg),
                Center(
                  child: Text(
                    l.terms,
                    style: text.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ]),
            ),
          ),
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.only(bottom: NamatSpace.xxl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isSignup ? l.haveAccount : l.noAccount,
                style: text.bodySmall,
              ),
              TextButton(
                onPressed: () =>
                    context.go(_isSignup ? '/login' : '/signup'),
                child: Text(_isSignup ? l.goLogin : l.goSignup),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
