import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One-time "how to link your phone" onboarding state.
///
/// Persists a single flag so the onboarding carousel is shown only once
/// (right after the splash screen) and never again on later launches.
class OnboardingProvider extends ChangeNotifier {
  static const _prefsKey = 'velie_onboarding_seen';

  bool _seen = false;
  bool _loaded = false;

  /// Whether the user has already finished onboarding.
  bool get isSeen => _seen;

  /// Whether the persisted flag has been read yet.
  bool get isLoaded => _loaded;

  /// Restores the persisted flag (defaults to not seen).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _seen = prefs.getBool(_prefsKey) ?? false;
    } catch (_) {
      _seen = false;
    }
    _loaded = true;
    notifyListeners();
  }

  /// Marks onboarding as finished. Idempotent — safe to call more than once.
  Future<void> markSeen() async {
    if (_seen) return;
    _seen = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, true);
    } catch (_) {
      // Best-effort persistence; in-memory flag still applies this session.
    }
  }
}
