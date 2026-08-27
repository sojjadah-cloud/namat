import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/phone_page.dart';
import '../../features/auth/presentation/setup_page.dart';
import '../../features/auth/presentation/verify_page.dart';
import '../../features/bookings/presentation/bookings_page.dart';
import '../../features/bookings/presentation/cart_page.dart';
import '../../features/bookings/presentation/checkout_page.dart';
import '../../features/bookings/presentation/order_done_page.dart';
import '../../features/challenges/presentation/challenges_page.dart';
import '../../features/challenges/presentation/create_duel_page.dart';
import '../../features/challenges/presentation/duel_room_page.dart';
import '../../features/challenges/presentation/duel_sent_page.dart';
import '../../features/challenges/presentation/find_opponent_page.dart';
import '../../features/favorites/presentation/favorites_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/journey/presentation/journey_page.dart';
import '../../features/notifications/presentation/notifications_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/onboarding/presentation/splash_page.dart';
import '../../features/onboarding/presentation/welcome_page.dart';
import '../../features/packages/presentation/packages_page.dart';
import '../../features/partners/presentation/partner_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/account/presentation/addresses_page.dart';
import '../../features/rewards/presentation/points_page.dart';
import '../../features/settings/presentation/settings_pages.dart';
import '../../features/reviews/presentation/rate_page.dart';
import '../../features/search/presentation/search_page.dart';
import '../../features/shell/app_shell.dart';
import '../../features/use/presentation/field_page.dart';
import '../../features/use/presentation/use_page.dart';

/// Routing.
///
/// Five tabs, named for what a member is doing rather than for what the app
/// contains: الرئيسية, استكشف, رحلتي, حجوزاتي, حسابي. Challenges used to hold a
/// tab of its own; it belongs under رحلتي, because a challenge is a way of
/// continuing rather than a separate product — and the destination it was
/// occupying left bookings, the thing members open most often, two taps deep.
///
/// Each tab lives inside a [StatefulShellRoute] so it keeps its own navigation
/// stack: opening a partner from استكشف, tapping رحلتي, then coming back
/// returns you to the partner rather than to the top of the tab. That is what
/// makes tab navigation feel native instead of like a set of links.
///
/// The order flow sits OUTSIDE the shell on purpose. Once a member is paying,
/// the bottom bar is a way to lose the cart, not a way to navigate.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomePage()),

      // Signing up and signing in are the same screen twice; only the copy
      // and the destination after verification differ.
      for (final mode in ['signup', 'login'])
        GoRoute(
          path: '/$mode',
          builder: (_, __) => PhonePage(mode: mode),
          routes: [
            GoRoute(
              path: 'verify',
              builder: (_, __) => VerifyPage(mode: mode),
            ),
          ],
        ),
      GoRoute(path: '/setup', builder: (_, __) => const SetupPage()),

      // Search is global and reached from every tab, so no one tab owns it.
      GoRoute(path: '/search', builder: (_, __) => const SearchPage()),

      GoRoute(path: '/cart', builder: (_, __) => const CartPage()),
      GoRoute(
        path: '/cart/checkout',
        builder: (_, __) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/cart/done/:reference',
        builder: (_, state) => OrderDonePage(
          reference: state.pathParameters['reference']!,
        ),
      ),
      GoRoute(
        path: '/rate/:reference',
        builder: (_, state) => RatePage(
          reference: state.pathParameters['reference']!,
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          // ------------------------------------------------------ الرئيسية
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

          // -------------------------------------------------------- استكشف
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
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

          // --------------------------------------------------------- رحلتي
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
                  GoRoute(
                    path: 'challenges',
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
            ],
          ),

          // ------------------------------------------------------- حجوزاتي
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (_, __) => const BookingsPage(),
              ),
            ],
          ),

          // --------------------------------------------------------- حسابي
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'favorites',
                    builder: (_, __) => const FavoritesPage(),
                  ),
                  GoRoute(
                    path: 'points',
                    builder: (_, __) => const PointsPage(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (_, __) => const SettingsPage(),
                    routes: [
                      GoRoute(
                        path: 'addresses',
                        builder: (_, __) => const AddressesPage(),
                      ),
                      GoRoute(
                        path: 'city',
                        builder: (_, __) => const CityPage(),
                      ),
                      GoRoute(
                        path: 'notifications',
                        builder: (_, __) => const NotificationPrefsPage(),
                      ),
                      GoRoute(
                        path: 'language',
                        builder: (_, __) => const LanguagePage(),
                      ),
                      GoRoute(
                        path: 'privacy',
                        builder: (_, __) => const PrivacyPage(),
                      ),
                      GoRoute(
                        path: 'support',
                        builder: (_, __) => const SupportPage(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
