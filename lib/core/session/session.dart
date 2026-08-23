import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/business_model.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/draft_service.dart';

/// The single source of truth for the whole app.
///
/// The session owns all the global data that "happens" in the app: the signed-in
/// business, its server-side plan, and the authentication token. Any file that
/// needs shared/global data should ask the session rather than reading / writing
/// scattered providers or storage keys directly.
///
/// Responsibilities:
///  - be the single holder of [business] / [plan] / [businessId] / token,
///  - persist the session locally under one `velie_session` key,
///  - re-sync the plan from the backend every 5s while signed in,
///  - on [logout] terminate the session and wipe all session-scoped local data
///    (drafts, auto-draft, media files, quick tags, WhatsApp instance) while
///    keeping device-level prefs (theme, onboarding).
class Session extends ChangeNotifier {
  Session({AuthService? service}) : _service = service ?? AuthService();

  final AuthService _service;

  static const _prefsKey = 'velie_session';
  static const _syncInterval = Duration(seconds: 5);

  BusinessModel? _business;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;
  Timer? _syncTimer;
  bool _syncing = false;
  bool _relinkRequired = false;

  /// The authenticated business (or null when signed out).
  BusinessModel? get business => _business;

  /// The signed-in user's plan (`free` / `pro` / `business`). The session is
  /// the owner of this value — it is refreshed on every login and re-synced
  /// from the server every 5s while the session is active.
  String get plan => _business?.plan ?? 'free';
  bool get isPro => plan.toLowerCase() == 'pro';

  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _business != null;
  bool get isLoading => _isLoading;
  bool get isSyncing => _syncing;
  String? get error => _error;
  int? get businessId => _business?.id;

  /// True when the WhatsApp instance was unlinked from the phone's "Linked
  /// Devices" (or the session was otherwise invalidated) and the user must
  /// re-pair before statuses can be posted again. The app root listens for
  /// this and shows the unclosable reconnect drawer.
  bool get relinkRequired => _relinkRequired;

  /// Set by [InstanceProvider] when the backend reports the instance went
  /// `disconnected` after having been connected.
  void setRelinkRequired(bool value) {
    if (_relinkRequired == value) return;
    _relinkRequired = value;
    notifyListeners();
  }

  /// The current auth token (also applied to [ApiClient] for every request).
  String? get accessToken => _business?.accessToken;

  /// Lightweight liveness probe for the backend (a 401/404/... still counts as
  /// "reachable" — only connection/timeout failures mean the backend is down).
  /// Lets the auth screens surface "seva haipatikani" before the user submits.
  Future<bool> isBackendReachable() => _service.isBackendReachable();

  /// Restores a persisted session from local storage.
  Future<void> loadSession() async {
    _isInitialized = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      var raw = prefs.getString(_prefsKey);
      // Migrate any session saved under the legacy key so existing installs
      // aren't logged out by the refactor.
      if (raw == null || raw.isEmpty) {
        raw = prefs.getString('velie_business');
        if (raw != null && raw.isNotEmpty) {
          await prefs.setString(_prefsKey, raw);
          await prefs.remove('velie_business');
        }
      }
      if (raw != null && raw.isNotEmpty) {
        try {
          _business = BusinessModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          final token = _business?.accessToken;
          if (token != null && token.isNotEmpty) {
            ApiClient.instance.authToken = token;
          }
        } catch (_) {
          _business = null;
        }
      }
    } catch (_) {
      // Storage unavailable — treat as signed out rather than blocking launch.
      _business = null;
    } finally {
      _isInitialized = true;
      if (isAuthenticated) _startSync();
      notifyListeners();
    }
  }

  /// Registers a new user, persists and starts the session (incl. plan sync).
  Future<void> register({
    required String name,
    required String ownerPhone,
    required String password,
  }) async {
    await _run(() async {
      _business = await _service.registerBusiness(
        name: name,
        ownerPhone: ownerPhone,
        password: password,
      );
    });
  }

  /// Logs in a user, persists and starts the session (incl. plan sync).
  Future<void> login({required String ownerPhone, required String password}) async {
    await _run(() async {
      _business = await _service.login(ownerPhone: ownerPhone, password: password);
    });
  }

  /// Requests a password-reset OTP (delivered as a WhatsApp self-message).
  Future<void> forgotPassword({required String ownerPhone}) =>
      _service.forgotPassword(ownerPhone: ownerPhone);

  /// Validates the OTP before allowing a password reset.
  Future<void> verifyOtp({required String ownerPhone, required String otp}) =>
      _service.verifyOtp(ownerPhone: ownerPhone, otp: otp);

  /// Resets the password and auto-logs-in with the returned token (persists
  /// the session and starts the plan sync exactly like login/register).
  Future<void> resetPassword({
    required String ownerPhone,
    required String newPassword,
  }) async {
    await _run(() async {
      _business = await _service.resetPassword(
        ownerPhone: ownerPhone,
        newPassword: newPassword,
      );
    });
  }

  /// Applies the token + persists after a successful auth call.
  Future<void> _run(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      final token = _business?.accessToken;
      if (token != null && token.isNotEmpty) {
        ApiClient.instance.authToken = token;
      }
      await _persist();
      _startSync();
    } catch (e) {
      _error = '$e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optimistically applies a new plan locally (e.g. right after subscribing).
  /// The next 5s sync re-confirms it against the server.
  void applyPlan(String plan) {
    final current = _business;
    if (current == null) return;
    _business = BusinessModel(
      id: current.id,
      name: current.name,
      ownerPhone: current.ownerPhone,
      plan: plan,
      accessToken: current.accessToken,
      createdAt: current.createdAt,
    );
    _persist();
    notifyListeners();
  }

  /// Re-fetches the business + plan from the server so the session stays in
  /// sync with billing changes. Returns true when the plan actually changed.
  Future<bool> syncProfile() async {
    if (!isAuthenticated || _syncing) return false;
    _syncing = true;
    try {
      final fresh = await _service.me();
      final changed = fresh.plan != plan;
      _merge(fresh);
      await _persist();
      notifyListeners();
      return changed;
    } catch (_) {
      return false;
    } finally {
      _syncing = false;
    }
  }

  void _merge(BusinessModel fresh) {
    final current = _business;
    _business = BusinessModel(
      id: fresh.id,
      name: fresh.name,
      ownerPhone: fresh.ownerPhone,
      plan: fresh.plan,
      accessToken: current?.accessToken ?? fresh.accessToken,
      createdAt: fresh.createdAt,
    );
  }

  void _startSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) => syncProfile());
  }

  void _stopSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Terminates the session and wipes all session-scoped local data so a new
  /// user starts completely fresh. Device-level prefs (theme, onboarding) are
  /// kept.
  Future<void> logout() async {
    _stopSync();
    _business = null;
    _relinkRequired = false;
    ApiClient.instance.authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    await _wipeSessionData(prefs);
    _runLogoutHandlers();
    notifyListeners();
  }

  final List<VoidCallback> _logoutHandlers = [];

  /// Registers a callback that runs when the session ends (logout). Used by
  /// feature providers (instance polling, quick tags, composer) to reset their
  /// in-memory state so the next login starts clean.
  void addLogoutHandler(VoidCallback handler) => _logoutHandlers.add(handler);

  void _runLogoutHandlers() {
    for (final handler in _logoutHandlers) {
      try {
        handler();
      } catch (_) {}
    }
  }

  Future<void> _wipeSessionData(SharedPreferences prefs) async {
    // WhatsApp instance.
    await prefs.remove('${InstancePrefsKey.instance}_id');

    // Quick tags (user-created reusable chips).
    await prefs.remove(VeliePrefKeys.quickTags);

    // Drafts, auto-draft + delete their media files on disk.
    await DraftService().clearAll();

    // Thumbnail-cache keys are namespaced per draft id, so sweep them.
    for (final key in prefs.getKeys().toList()) {
      if (key.startsWith(VeliePrefKeys.draftThumbnailPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  @override
  void dispose() {
    _stopSync();
    super.dispose();
  }

  Future<void> _persist() async {
    final current = _business;
    if (current == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(current.toJson()));
  }
}

/// Central registry of the app's shared_preferences keys so the session can
/// wipe every session-scoped piece of user data on logout.
class VeliePrefKeys {
  VeliePrefKeys._();

  static const quickTags = 'velie_quick_tags';
  static const onBoardingSeen = 'velie_onboarding_seen';
  static const draftThumbnailPrefix = 'velie_draft_thumbnails:';
}

/// WhatsApp instance storage key.
class InstancePrefsKey {
  InstancePrefsKey._();
  static const instance = 'velie_instance';
}
