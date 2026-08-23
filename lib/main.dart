import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/session/session.dart';
import 'providers/auth_provider.dart';
import 'providers/create_post_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/instance_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/network_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/queue_provider.dart';
import 'providers/quick_tags_provider.dart';
import 'providers/update_provider.dart';
import 'services/auth_service.dart';
import 'services/instance_service.dart';
import 'services/mock/mock_auth_service.dart';
import 'services/mock/mock_instance_service.dart';
import 'services/mock/mock_schedule_service.dart';
import 'services/schedule_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // Transparent status bar (charcoal shows through), light icons on dark bg.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Load persisted locale before the first frame so there is no flash.
  final localeProvider = LocaleProvider();
  await localeProvider.load();

  final simulate = AppConstants.simulationEnabled;
  final authService = simulate ? MockAuthService() : AuthService();
  final instanceService = simulate ? MockInstanceService() : InstanceService();
  final scheduleService = simulate ? MockScheduleService() : ScheduleService();

  runApp(
    VelieRoot(
      authService: authService,
      instanceService: instanceService,
      scheduleService: scheduleService,
      localeProvider: localeProvider,
    ),
  );
}

class VelieRoot extends StatelessWidget {
  const VelieRoot({
    super.key,
    required this.authService,
    required this.instanceService,
    required this.scheduleService,
    required this.localeProvider,
  });

  final AuthService authService;
  final InstanceService instanceService;
  final ScheduleService scheduleService;
  final LocaleProvider localeProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        // The single source of truth — registered first so every other
        // provider/screen can ask the session for global data.
        ChangeNotifierProvider(
          create: (_) => Session(service: authService),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<Session>()),
        ),
        ChangeNotifierProvider(
          create: (context) {
            final session = context.read<Session>();
            final provider = InstanceProvider(service: instanceService, session: session);
            session.addLogoutHandler(provider.resetSession);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) {
            final session = context.read<Session>();
            final provider = CreatePostProvider(service: scheduleService, session: session);
            session.addLogoutHandler(provider.reset);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final session = context.read<Session>();
            final provider = QuickTagsProvider();
            session.addLogoutHandler(provider.reset);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => UpdateProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NetworkProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, DashboardProvider>(
          create: (context) => DashboardProvider(service: scheduleService),
          update: (_, auth, dashboard) {
            dashboard ??= DashboardProvider(service: scheduleService);
            dashboard.setBusinessId(auth.businessId);
            return dashboard;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, QueueProvider>(
          create: (context) => QueueProvider(service: scheduleService),
          update: (_, auth, queue) {
            queue ??= QueueProvider(service: scheduleService);
            queue.setBusinessId(auth.businessId);
            return queue;
          },
        ),
      ],
      child: const VelieApp(),
    );
  }
}
