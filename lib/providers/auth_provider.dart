import 'package:flutter/foundation.dart';

import '../core/session/session.dart';
import '../models/business_model.dart';

/// Thin view-model over the central [Session].
///
/// The session file is the single source of truth for the business, plan and
/// token. This provider keeps its public API (so existing screens and the
/// router guard keep working) while delegating all state to the session and
/// re-broadcasting session changes to its own listeners.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._session) {
    _session.addListener(_forward);
  }

  final Session _session;

  void _forward() => notifyListeners();

  @override
  void dispose() {
    _session.removeListener(_forward);
    super.dispose();
  }

  BusinessModel? get business => _session.business;
  bool get isInitialized => _session.isInitialized;
  bool get isAuthenticated => _session.isAuthenticated;
  bool get isLoading => _session.isLoading;
  bool get isSyncing => _session.isSyncing;
  String? get error => _session.error;
  int? get businessId => _session.businessId;
  String get plan => _session.plan;
  bool get isPro => _session.isPro;

  /// Direct access to the underlying session for widgets that need it.
  Session get session => _session;

  Future<void> loadSession() => _session.loadSession();
  Future<void> register({
    required String name,
    required String ownerPhone,
    required String password,
  }) =>
      _session.register(name: name, ownerPhone: ownerPhone, password: password);
  Future<void> login({
    required String ownerPhone,
    required String password,
  }) =>
      _session.login(ownerPhone: ownerPhone, password: password);

  /// Requests a password-reset OTP (delivered as a WhatsApp self-message).
  Future<void> forgotPassword({required String ownerPhone}) =>
      _session.forgotPassword(ownerPhone: ownerPhone);

  /// Validates the OTP before allowing a password reset.
  Future<void> verifyOtp({required String ownerPhone, required String otp}) =>
      _session.verifyOtp(ownerPhone: ownerPhone, otp: otp);

  /// Resets the password and auto-logs-in (session persisted + plan sync on).
  Future<void> resetPassword({
    required String ownerPhone,
    required String newPassword,
  }) =>
      _session.resetPassword(ownerPhone: ownerPhone, newPassword: newPassword);

  void applyPlan(String plan) => _session.applyPlan(plan);
  Future<void> logout() => _session.logout();
  Future<bool> isBackendReachable() => _session.isBackendReachable();
}
