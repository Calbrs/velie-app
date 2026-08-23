import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../screens/create_post/create_post_hub_screen.dart';
import '../../screens/create_post/types/text_status_screen.dart';
import '../../screens/create_post/image_drafts_screen.dart';
import '../../screens/create_post/types/image_status_screen.dart';
import '../../screens/create_post/types/video_status_screen.dart';
import '../../screens/create_post/video_drafts_screen.dart';
import '../../screens/create_post/types/render_video_screen.dart';
import '../../screens/create_post/schedule_post_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/dashboard/notifications_screen.dart';
import '../../screens/onboarding/auth_screen.dart';
import '../../screens/onboarding/login_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/onboarding/pairing_code_screen.dart';
import '../../screens/onboarding/forgot_password_screen.dart';
import '../../screens/onboarding/verify_otp_screen.dart';
import '../../screens/onboarding/reset_password_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/queue/post_detail_screen.dart';
import '../../screens/queue/posts_queue_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/updater/updater_screen.dart';

/// go_router config + auth / instance guards.
abstract class AppRouter {
  static Page<dynamic> _buildSmoothTransitionPage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideIn = Tween<Offset>(
          begin: const Offset(0.0, 0.05),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final fadeIn = CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        );

        return FadeTransition(
          opacity: fadeIn,
          child: SlideTransition(
            position: slideIn,
            child: child,
          ),
        );
      },
    );
  }

  /// Global back-navigation used by every screen's back button.
  ///
  /// Pops to the previous route when one exists (so screens return to where
  /// they came from), otherwise falls back to a valid top-level screen instead
  /// of failing on a dead path.
  static void back(BuildContext context, {String fallback = '/dashboard'}) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallback);
    }
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    final auth = context.read<AuthProvider>();
    final location = state.matchedLocation;

    // Splash is still loading session — hold everything there.
    if (!auth.isInitialized) {
      return location == '/' ? null : '/';
    }

    // The one-time phone-linking guide is shown before auth and is reachable
    // in any signed-in state; the screen's own "Continue" decides where to go.
    if (location == '/onboarding' || location == '/updater') {
      return null;
    }

    // No session → authentication (register), or stay on login / the
    // password-reset flow (forgot-password, verify-otp, reset-password).
    if (!auth.isAuthenticated) {
      const publicPaths = {
        '/auth',
        '/login',
        '/forgot-password',
        '/verify-otp',
        '/reset-password',
      };
      return publicPaths.contains(location) ? null : '/auth';
    }

    // All good — but keep onboarding screens out of the way.
    if (location == '/auth' || location == '/login') {
      return '/dashboard';
    }
    return null;
  }

  static GoRouter createRouter({Listenable? refreshListenable, GlobalKey<NavigatorState>? navigatorKey}) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: refreshListenable,
      navigatorKey: navigatorKey,
      redirect: _redirect,
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
          ),
        ),
        GoRoute(
          path: '/updater',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const UpdaterScreen(),
          ),
        ),
        GoRoute(
          path: '/onboarding',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const OnboardingScreen(),
          ),
        ),
        GoRoute(
          path: '/auth',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const AuthScreen(),
          ),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/forgot-password',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const ForgotPasswordScreen(),
          ),
        ),
        GoRoute(
          path: '/verify-otp',
          pageBuilder: (_, state) {
            final phone = state.extra as String? ?? '';
            return _buildSmoothTransitionPage(
              key: state.pageKey,
              child: VerifyOtpScreen(phone: phone),
            );
          },
        ),
        GoRoute(
          path: '/reset-password',
          pageBuilder: (_, state) {
            final phone = state.extra as String? ?? '';
            return _buildSmoothTransitionPage(
              key: state.pageKey,
              child: ResetPasswordScreen(phone: phone),
            );
          },
        ),
        GoRoute(
          path: '/connect',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const PairingCodeScreen(),
          ),
        ),
        GoRoute(
          path: '/dashboard',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const NotificationsScreen(),
          ),
        ),
        GoRoute(
          path: '/post/create',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const CreatePostHubScreen(),
          ),
        ),
        GoRoute(
          path: '/post/create/text',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const TextStatusScreen(),
          ),
        ),
        GoRoute(
          path: '/post/create/image',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const ImageDraftsScreen(),
          ),
        ),
        GoRoute(
          path: '/post/create/image/editor',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const ImageStatusScreen(),
          ),
        ),
        GoRoute(
          path: '/post/create/video',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const VideoDraftsScreen(),
          ),
        ),
        GoRoute(
          path: '/post/create/video/editor',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const VideoStatusScreen(),
          ),
        ),
        GoRoute(
          path: '/post/schedule',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const SchedulePostScreen(),
          ),
        ),
        GoRoute(
          path: '/post/render',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: RenderVideoScreen(
              options: state.extra as VideoRenderOptions?,
            ),
          ),
        ),
        GoRoute(
          path: '/queue',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const PostsQueueScreen(),
          ),
        ),
        GoRoute(
          path: '/queue/:id',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: PostDetailScreen(
              postId: int.parse(state.pathParameters['id'] ?? '0'),
            ),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (_, state) => _buildSmoothTransitionPage(
            key: state.pageKey,
            child: const ProfileScreen(),
          ),
        ),
      ],
    );
  }
}