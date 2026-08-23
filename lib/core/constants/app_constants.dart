import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Global app constants and configuration.
abstract class AppConstants {
  /// Compile-time override (--dart-define=API_BASE_URL=...). Wins over .env so
  /// release APKs bake the production URL without ever editing a config file.
  static const _compileTimeApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_compileTimeApiBaseUrl.isNotEmpty) return _compileTimeApiBaseUrl;
    final fromEnv = dotenv.env['API_BASE_URL'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    // Default = persistent DEV runtime on OCI, so plain `flutter run` targets
    // DEV (scheduler keeps running even when the laptop is off). Production
    // APKs override this at build time via deploy_apk.ps1 --dart-define.
    return 'https://dev-velie.calbrs.com/api';
  }

  /// Origin (scheme + host) used to build absolute media URLs from the
  /// backend's relative `/uploads/...` paths.
  static String get apiOrigin {
    final base = apiBaseUrl;
    final trimmed = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    if (trimmed.endsWith('/api')) return trimmed.substring(0, trimmed.length - 4);
    return trimmed;
  }

  /// Turns a backend `media_url` (relative or absolute) into a renderable URL.
  static String? resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final normalized = path.startsWith('/') ? path : '/$path';
    return '$apiOrigin$normalized';
  }

  /// When true, services return mock data so the whole app flow can be
  /// explored without a running backend (SIMULATION_MODE in .env).
  static bool get simulationEnabled =>
      dotenv.env['SIMULATION_MODE']?.toLowerCase() == 'true';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 120);
  static const Duration sendTimeout = Duration(seconds: 120);

  /// How often [InstanceProvider] polls instance status while connecting.
  static const Duration instancePollInterval = Duration(seconds: 1);

  /// How often [InstanceProvider] re-checks status while connected, so a later
  /// unlink from WhatsApp "Linked Devices" is detected (the webhook flips the
  /// backend status to `disconnected` and this poll picks it up).
  static const Duration instanceConnectedPollInterval = Duration(seconds: 5);

  /// Delay after instance becomes connected before navigating to dashboard.
  static const Duration connectedCelebrationDelay = Duration(milliseconds: 300);

  /// Minimum time the splash screen stays visible so it doesn't flash past.
  static const Duration splashMinimumDisplay = Duration(milliseconds: 400);

  /// Time a pairing code stays valid before a new one is needed.
  static const Duration pairingCodeLifetime = Duration(minutes: 4);

  /// WhatsApp country prefix used for [owner_phone].
  static const String phonePrefix = '+255';

  /// Dispatch gap between scheduled posts (backend anti-ban).
  static const String dispatchDisclaimer =
      'Posts zinazopangwa kwa wakati mmoja hutumwa kwa nafasi ya sekunde 30–60 kila moja.';
}
