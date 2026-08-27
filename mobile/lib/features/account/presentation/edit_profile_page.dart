import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/city.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/domain/profile_draft.dart';
import '../domain/session.dart';

/// Name, handle and city.
///
/// The handle is the only field here with a rule attached, and the rule is
/// about being passed on: someone types it into a search box to challenge you,
/// so it stays Latin and lowercase. A handle that has to be spelled in two
/// scripts is a handle nobody can repeat.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _name;
  late final TextEditingController _username;
  late NamatCity _city;
  bool _showUsernameError = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionProvider);
    _name = TextEditingController(
      text: session.name.isEmpty
          ? ref.read(profileDraftProvider).name
          : session.name,
    );
    _username = TextEditingController(text: session.username);
    _city = session.city;
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  void _save() {
    final username = _username.text.trim().toLowerCase();

    // An empty handle is allowed — it is optional until someone wants to be
    // findable. A malformed one is not, because it would be saved and then
    // silently fail to match anything.
    if (username.isNotEmpty && !isValidUsername(username)) {
      setState(() => _showUsernameError = true);
      return;
    }

    final l = L.of(context)!;
    ref.read(sessionProvider.notifier)
      ..setName(_name.text.trim())
      ..setUsername(username)
      ..setCity(_city);
    // The draft feeds the greeting on first launch; keeping it in step means
    // the name does not revert on the next cold start.
    ref.read(profileDraftProvider.notifier).setName(_name.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.saved2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const NamatBack(fallback: '/profile'),
          title: Text(l.editProfile),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.lg,
            NamatSpace.gutter,
            140,
          ),
          children: revealAll([
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l.nameLabel,
                hintText: l.nameHint,
              ),
            ),
            const SizedBox(height: NamatSpace.xl),

            // Pinned left-to-right and shown with its at-sign, because that is
            // how it will be read back everywhere else in the app.
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: _username,
                autocorrect: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                  LengthLimitingTextInputFormatter(20),
                ],
                onChanged: (_) {
                  if (_showUsernameError) {
                    setState(() => _showUsernameError = false);
                  }
                },
                decoration: InputDecoration(
                  labelText: l.usernameLabel,
                  hintText: l.usernameHint,
                  prefixText: '@',
                  errorText: _showUsernameError ? l.usernameInvalid : null,
                ),
              ),
            ),
            const SizedBox(height: NamatSpace.sm),
            Text(l.usernameRules, style: text.labelSmall),
            const SizedBox(height: 4),
            // Said plainly. Without a server nothing can be reserved, and
            // letting a member believe otherwise sets up a collision they
            // would only discover after launch.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.info_outline,
                    size: 13,
                    color: NamatColors.inkSoft,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(l.usernameNotChecked, style: text.labelSmall),
                ),
              ],
            ),

            const SizedBox(height: NamatSpace.xxl),
            Text(l.cityTitle, style: text.labelMedium),
            const SizedBox(height: NamatSpace.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final city in NamatCity.values)
                  Pressable(
                    onTap: () => setState(() => _city = city),
                    child: AnimatedContainer(
                      duration: NamatMotion.fast,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: city == _city
                            ? NamatColors.deep
                            : NamatColors.surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: city == _city
                              ? NamatColors.deep
                              : NamatColors.line,
                        ),
                      ),
                      child: Text(
                        city.label(l),
                        style: text.labelMedium?.copyWith(
                          color: city == _city
                              ? Colors.white
                              : NamatColors.ink,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ]),
        ),
        bottomSheet: Container(
          color: NamatColors.canvas,
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.md,
            NamatSpace.gutter,
            NamatSpace.xxl,
          ),
          child: FilledButton(
            onPressed: _save,
            child: Text(l.saveChanges),
          ),
        ),
      ),
    );
  }
}
