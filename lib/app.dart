import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/session/session.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/instance_provider.dart';
import 'providers/queue_provider.dart';
import 'widgets/common/global_network_drawer.dart';
import 'widgets/common/primary_button.dart';

/// App root — MaterialApp.router wired to the guard-driven GoRouter.
///
/// The app is dark-only: it always builds the dark theme and never offers a
/// light/system toggle.
class VelieApp extends StatefulWidget {
  const VelieApp({super.key});

  @override
  State<VelieApp> createState() => _VelieAppState();
}

class _VelieAppState extends State<VelieApp> {
  GoRouter? _router;
  _AuthInstanceGuard? _guard;
  Session? _session;
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _relinkSheetVisible = false;
  Timer? _globalSyncTimer;

  @override
  void initState() {
    super.initState();
    _globalSyncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _performGlobalSync();
    });
  }

  void _performGlobalSync() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      context.read<DashboardProvider>().refresh(silent: true);
      context.read<QueueProvider>().refresh(silent: true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_router == null) {
      final auth = context.read<AuthProvider>();
      final inst = context.read<InstanceProvider>();
      _guard = _AuthInstanceGuard(auth, inst);
      _router = AppRouter.createRouter(
        refreshListenable: _guard,
        navigatorKey: _navigatorKey,
      );
    }
    final session = context.read<Session>();
    if (!identical(_session, session)) {
      _session?.removeListener(_onSessionChanged);
      _session = session;
      _session!.addListener(_onSessionChanged);
    }
  }

  @override
  void dispose() {
    _globalSyncTimer?.cancel();
    _session?.removeListener(_onSessionChanged);
    _guard?.dispose();
    super.dispose();
  }

  /// Reacts to the session's relink-required state: shows the unclosable
  /// reconnect drawer when the WhatsApp instance was unlinked, and dismisses
  /// it once the instance is connected (or pending) again.
  void _onSessionChanged() {
    final session = _session;
    if (session == null) return;
    final authenticated = context.read<AuthProvider>().isAuthenticated;

    if (session.relinkRequired && authenticated) {
      // Skip when already on the pairing screen (the user is re-linking).
      final location = _router?.state.matchedLocation;
      if (location != '/connect') {
        _showRelinkSheet();
      }
    } else {
      _dismissRelinkSheet();
    }
  }

  void _showRelinkSheet() {
    if (_relinkSheetVisible || !mounted) return;
    final overlayContext = _navigatorKey.currentState?.overlay?.context;
    if (overlayContext == null) return;
    _relinkSheetVisible = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_relinkSheetVisible) return;
      showModalBottomSheet<void>(
        context: overlayContext,
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) => PopScope<void>(
          canPop: false,
          child: _ReconnectSheet(
            onReconnect: () {
              _relinkSheetVisible = false;
              Navigator.of(sheetContext).pop();
              // The pairing screen refreshes the code for the same instance
              // (same phone number) as soon as it opens.
              _router?.go('/connect');
            },
          ),
        ),
      ).whenComplete(() => _relinkSheetVisible = false);
    });
  }

  void _dismissRelinkSheet() {
    if (!_relinkSheetVisible) return;
    _relinkSheetVisible = false;
    final navigator = _navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
    }
  }

  void _applySystemOverlay(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dark-only: force the dark palette so no light colors can ever render.
    AppColors.mode = AppColorMode.dark;
    _applySystemOverlay(Brightness.dark);
    return MaterialApp.router(
      title: 'Velie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: _router!,
      builder: (context, child) {
        return GlobalNetworkDrawer(child: child!);
      },
    );
  }
}

/// Unclosable bottom drawer shown when the WhatsApp instance was unlinked from
/// the phone's "Linked Devices". The only way out is to re-link — the button
/// routes to the pairing screen, which generates a fresh code for the same
/// phone number.
class _ReconnectSheet extends StatelessWidget {
  const _ReconnectSheet({required this.onReconnect});

  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.statusFailed.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.link_off, color: AppColors.statusFailed, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Muunganisho umekatwa',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'WhatsApp iliondolewa kwenye Vifaa Vilivyounganishwa (Linked Devices) kwenye simu yako. '
              'Unganisha tena ili uendelee kutuma status.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Unganisha Tena',
              icon: Icons.phone_android,
              onPressed: onReconnect,
            ),
          ],
        ),
      ),
    );
  }
}

/// Notifies the GoRouter whenever auth/instance state changes so redirect
/// guards are re-evaluated automatically.
class _AuthInstanceGuard extends ChangeNotifier {
  _AuthInstanceGuard(this._auth, this._inst) {
    _auth.addListener(_notify);
    _inst.addListener(_notify);
  }

  final AuthProvider _auth;
  final InstanceProvider _inst;

  void _notify() => notifyListeners();

  @override
  void dispose() {
    _auth.removeListener(_notify);
    _inst.removeListener(_notify);
    super.dispose();
  }
}
