import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/city.dart';
import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../account/domain/session.dart';
import '../domain/profile_draft.dart';

/// Setting up: one question per screen.
///
/// One long form collects the same answers and teaches nothing. Asked one at a
/// time, each answer visibly changes what NAMAT will do — and only the goal is
/// required, because personalisation that refuses to begin until it knows your
/// city is a form, and people leave forms.
class SetupPage extends ConsumerStatefulWidget {
  const SetupPage({super.key});

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends ConsumerState<SetupPage> {
  int _step = 0;
  static const _steps = 5;

  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    // Seeded from whatever is already stored, so a member who reloads mid-way
    // through setup does not find the field blank while the app is greeting
    // them by name on the next screen.
    _name = TextEditingController(text: ref.read(profileDraftProvider).name)
      ..addListener(
        // Written down on every keystroke rather than when the step is left.
        // Advancing was the only thing that saved it, so a name typed and then
        // abandoned — by a reload, or by backing out — was simply gone.
        () => ref
            .read(profileDraftProvider.notifier)
            .setName(_name.text.trim()),
      );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _steps - 1) {
      setState(() => _step++);
    } else {
      // The answers move from the draft into the session, which is what the
      // rest of the app reads. A skipped city falls back to the launch market
      // rather than to nothing.
      final draft = ref.read(profileDraftProvider);
      ref.read(sessionProvider.notifier)
        ..signIn(name: draft.name)
        ..setCity(NamatCity.byName(draft.city ?? '') ?? NamatCity.launch);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final draft = ref.watch(profileDraftProvider);
    final notifier = ref.read(profileDraftProvider.notifier);

    // Only the goal blocks progress. Everything else can be skipped.
    final canAdvance = _step != 1 || draft.goal != null;
    final isLast = _step == _steps - 1;

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: _step == 0
              ? null
              : IconButton(
                  onPressed: () => setState(() => _step--),
                  icon: const Icon(Icons.arrow_back),
                ),
          title: Text(
            l.stepOf(context.n(_step + 1), context.n(_steps)),
            style: text.labelSmall,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NamatSpace.gutter,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: (_step + 1) / _steps),
                  duration: NamatMotion.base,
                  curve: NamatMotion.enter,
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 5,
                    backgroundColor: NamatColors.line,
                    valueColor:
                        const AlwaysStoppedAnimation(NamatColors.deep),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: NamatMotion.base,
                switchInCurve: NamatMotion.enter,
                child: SingleChildScrollView(
                  // The key is what makes AnimatedSwitcher treat each step as
                  // a different child rather than the same one rebuilt.
                  key: ValueKey(_step),
                  padding: const EdgeInsets.fromLTRB(
                    NamatSpace.gutter,
                    NamatSpace.section,
                    NamatSpace.gutter,
                    NamatSpace.xl,
                  ),
                  child: switch (_step) {
                    0 => _Question(
                        title: l.qNameTitle,
                        child: TextField(
                          controller: _name,
                          autofocus: true,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(hintText: l.qNameHint),
                          onSubmitted: (_) => _next(),
                        ),
                      ),
                    1 => _Question(
                        title: l.qGoalTitle,
                        body: l.qGoalBody,
                        child: Column(
                          children: [
                            for (final g in Goal.values)
                              _Choice(
                                label: _goalLabel(g, l),
                                selected: draft.goal == g,
                                onTap: () => notifier.setGoal(g),
                              ),
                          ],
                        ),
                      ),
                    2 => _Question(
                        title: l.qActivityTitle,
                        child: Column(
                          children: [
                            for (final a in ActivityLevel.values)
                              _Choice(
                                label: _activityLabel(a, l),
                                selected: draft.activity == a,
                                onTap: () => notifier.setActivity(a),
                              ),
                          ],
                        ),
                      ),
                    3 => _Question(
                        title: l.qCityTitle,
                        body: l.qCityBody,
                        child: Column(
                          children: [
                            // Sohar first: it is the launch market, and the
                            // order of a list is a recommendation whether or
                            // not it is meant as one.
                            for (final c in NamatCity.values)
                              _Choice(
                                label: c.label(l),
                                selected: draft.city == c.name,
                                onTap: () => notifier.setCity(c.name),
                              ),
                          ],
                        ),
                      ),
                    _ => _Question(
                        title: l.qInterestsTitle,
                        body: l.qInterestsBody,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final i in Interest.values)
                              _Pill(
                                label: _interestLabel(i, l),
                                icon: _interestIcon(i),
                                selected: draft.interests.contains(i),
                                onTap: () => notifier.toggleInterest(i),
                              ),
                          ],
                        ),
                      ),
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NamatSpace.gutter,
                0,
                NamatSpace.gutter,
                NamatSpace.xxl,
              ),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: canAdvance ? _next : null,
                    child: Text(isLast ? l.finishSetup : l.nextStep),
                  ),
                  if (_step != 1)
                    TextButton(
                      onPressed: _next,
                      child: Text(l.skipStep),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _goalLabel(Goal g, L l) => switch (g) {
        Goal.lose => l.goalLose,
        Goal.active => l.goalActive,
        Goal.muscle => l.goalMuscle,
        Goal.start => l.goalStart,
        Goal.maintain => l.goalMaintain,
      };

  static String _activityLabel(ActivityLevel a, L l) => switch (a) {
        ActivityLevel.low => l.activityLow,
        ActivityLevel.moderate => l.activityModerate,
        ActivityLevel.active => l.activityActive,
        ActivityLevel.very => l.activityVery,
      };

  static String _interestLabel(Interest i, L l) => switch (i) {
        Interest.meals => l.fieldMeals,
        Interest.fitness => l.fieldFitness,
        Interest.consult => l.fieldConsult,
        Interest.store => l.fieldStores,
        Interest.challenges => l.challengesTitle,
      };

  static NamatIcons _interestIcon(Interest i) => switch (i) {
        Interest.meals => NamatIcons.meals,
        Interest.fitness => NamatIcons.fitness,
        Interest.consult => NamatIcons.consultation,
        Interest.store => NamatIcons.store,
        Interest.challenges => NamatIcons.challenge,
      };
}

class _Question extends StatelessWidget {
  const _Question({required this.title, required this.child, this.body});

  final String title;
  final String? body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.displayMedium),
        if (body != null) ...[
          const SizedBox(height: NamatSpace.sm),
          Text(body!, style: text.bodySmall),
        ],
        const SizedBox(height: NamatSpace.xxl),
        child,
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: NamatSpace.sm),
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: NamatMotion.fast,
          curve: NamatMotion.enter,
          padding: const EdgeInsets.all(NamatSpace.lg),
          decoration: BoxDecoration(
            color: selected ? NamatColors.greenSoft : NamatColors.surface,
            borderRadius: BorderRadius.circular(NamatRadius.sm),
            border: Border.all(
              color: selected ? NamatColors.deep : NamatColors.line,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: text.bodyMedium)),
              AnimatedScale(
                scale: selected ? 1 : 0,
                duration: NamatMotion.fast,
                curve: NamatMotion.enter,
                child: const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: NamatColors.deep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final NamatIcons icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: NamatMotion.fast,
        curve: NamatMotion.enter,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? NamatColors.deep : NamatColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? NamatColors.deep : NamatColors.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NamatIcon(
              icon,
              size: 18,
              color: selected ? Colors.white : NamatColors.inkSoft,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: text.labelMedium?.copyWith(
                color: selected ? Colors.white : NamatColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
