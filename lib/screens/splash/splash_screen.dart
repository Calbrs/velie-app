import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/instance_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/update_provider.dart';

/// Decides where the user lands on launch.
///
/// Bootstraps the session + instance state, then navigates explicitly
/// (the router guard also re-evaluates on state changes, but navigating
/// here guarantees we never sit on the splash forever).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final startedAt = DateTime.now();
    final auth = context.read<AuthProvider>();
    final inst = context.read<InstanceProvider>();
    final onboarding = context.read<OnboardingProvider>();
    await auth.loadSession();
    await onboarding.load();
    // Always finish instance bootstrap (even signed out, so logout → connect
    // state is known) but only hit the network when a session exists.
    await inst.initialize();
    if (!auth.isAuthenticated) {
      inst.stopPolling();
    } else {
      // Signed-in user: background-check whether they already have a WhatsApp
      // instance. If yes, skip the linking flow and go straight to the
      // dashboard; only users with no instance generate a pairing code.
      await inst.checkHasInstance();
    }

    // Check if an update is already downloaded and ready
    if (!mounted) return;
    final updateProvider = context.read<UpdateProvider>();
    final hasUpdateReady = await updateProvider.checkIsReadyInitially();
    if (!hasUpdateReady) {
      // If not, silently check and download in background
      updateProvider.checkForUpdateAndDownload();
    }

    // Keep the splash visible for a moment so it doesn't flash past.
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < AppConstants.splashMinimumDisplay) {
      await Future.delayed(AppConstants.splashMinimumDisplay - elapsed);
    }
    if (!mounted) return;

    if (hasUpdateReady) {
      context.go('/updater');
      return;
    }

    // One-time phone-linking guide runs first (the screen continues the flow).
    if (!onboarding.isSeen) {
      context.go('/onboarding');
      return;
    }

    if (!auth.isAuthenticated) {
      context.go('/auth');
    } else if (!inst.hasInstance) {
      context.go('/connect');
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logo_velie.png',
          width: 144,
          height: 144,
          errorBuilder: (_, _, _) => _fallbackLogo(),
        ),
      ),
    );
  }

  Widget _fallbackLogo() {
    return Container(
      width: 144,
      height: 144,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'V',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: AppColors.buttonPrimary,
          ),
        ),
      ),
    );
  }
}