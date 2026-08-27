import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/challenges/presentation/challenges_page.dart';
import '../../features/challenges/presentation/create_duel_page.dart';
import '../../features/challenges/presentation/duel_room_page.dart';
import '../../features/challenges/presentation/duel_sent_page.dart';
import '../../features/challenges/presentation/find_opponent_page.dart';
import '../../features/notifications/presentation/notifications_page.dart';
import '../../features/packages/presentation/packages_page.dart';
import '../../features/partners/presentation/partner_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/journey/presentation/journey_page.dart';
import '../../features/onboarding/presentation/splash_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/onboarding/presentation/welcome_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/shell/app_shell.dart';
import '../../features/use/presentation/use_page.dart';
import '../../features/use/presentation/field_page.dart';

/// Routing.
///
/// The five tabs live inside a [StatefulShellRoute] so each keeps its own
/// navigation stack: opening a partner from Use NAMAT and then tapping Journey
/// and back returns you to the partner, not to the top of the tab. That is
/// what makes tab navigation feel native rather than like a set of links.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomePage()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    builder: (_, __) => const NotificationsPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/use',
                builder: (_, __) => const UsePage(),
                routes: [
                  GoRoute(
                    path: ':field',
                    builder: (_, state) =>
                        FieldPage(fieldKey: state.pathParameters['field']!),
                    routes: [
                      GoRoute(
                        path: 'partner/:slug',
                        builder: (_, state) => PartnerPage(
                          slug: state.pathParameters['slug']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/challenges',
                builder: (_, __) => const ChallengesPage(),
                routes: [
                  GoRoute(
                    path: 'find',
                    builder: (_, __) => const FindOpponentPage(),
                  ),
                  GoRoute(
                    path: 'new/:username',
                    builder: (_, state) => CreateDuelPage(
                      username: state.pathParameters['username']!,
                    ),
                  ),
                  GoRoute(
                    path: 'sent/:username',
                    builder: (_, state) => DuelSentPage(
                      username: state.pathParameters['username']!,
                    ),
                  ),
                  GoRoute(
                    path: 'room',
                    builder: (_, __) => const DuelRoomPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journey',
                builder: (_, __) => const JourneyPage(),
                routes: [
                  GoRoute(
                    path: 'packages',
                    builder: (_, __) => const PackagesPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfilePage())],
          ),
        ],
      ),
    ],
  );
});
