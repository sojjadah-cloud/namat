import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/accounts.dart';
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

  /// Set when the number turns out to belong on the other screen: true when it
  /// is already registered and this is sign-up, false when it is not and this
  /// is sign-in. Null while neither applies.
  bool? _wrongDoor;

  bool get _isSignup => widget.mode == 'signup';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text;
    if (!isValidPhone(raw)) {
      setState(() {
        _error = L.of(context)!.invalidPhone;
        _wrongDoor = null;
      });
      return;
    }

    final phone = normalisePhone(raw);
    ref.read(profileDraftProvider.notifier).setPhone(phone);

    // Signing up with a number that already has an account walks the member
    // through every setup question again only to arrive at the account they
    // already had. Signing in with one that has none sends a correct code to
    // a member who then has nothing to sign in to. Both are the same mistake,
    // and the app knows the answer before either happens.
    final registered = ref.read(accountsProvider.notifier).isRegistered(phone);
    // Signing up and finding it registered, or signing in and finding it is
    // not: the two cases where the member is at the wrong door.
    if (registered == _isSignup) {
      // The number is fine; only the door is wrong. Offered rather than
      // taken: they typed a number, not an intention to be moved, and they
      // may have meant to use a different one.
      //
      // Inline rather than in a sheet. A sheet has to close before a route can
      // be pushed, and doing both in one gesture collides with the transition
      // already in flight — but more than that, the member is looking at the
      // field they just filled in, which is where the answer belongs.
      setState(() => _wrongDoor = registered);
      return;
    }

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
          leading: const NamatBack(fallback: '/welcome'),
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
                if (_wrongDoor case final registered?) ...[
                  const SizedBox(height: NamatSpace.lg),
                  NamatCard(
                    color: NamatColors.greenSoft,
                    elevated: false,
                    padding: const EdgeInsets.all(NamatSpace.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          registered
                              ? l.alreadyRegistered
                              : l.notRegistered,
                          style: text.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          registered
                              ? l.alreadyRegisteredBody
                              : l.notRegisteredBody,
                          style: text.labelSmall,
                        ),
                        const SizedBox(height: NamatSpace.md),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            // Straight to the code: the number is typed and
                            // already stored, so asking for it again on the
                            // other screen is asking twice for one answer.
                            onPressed: () => context.go(
                              registered
                                  ? '/login/verify'
                                  : '/signup/verify',
                            ),
                            child: Text(
                              registered ? l.goToLogin : l.goToSignup,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: NamatSpace.xl),
                FilledButton(
                  // Disabled once the number is known to belong elsewhere.
                  // Leaving it live would let a member walk into the flow the
                  // screen has just told them is the wrong one.
                  onPressed: _wrongDoor == null ? _submit : null,
                  child: Text(l.continueCta),
                ),
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
