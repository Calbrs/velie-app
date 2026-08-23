import 'package:dio/dio.dart';

import '../models/business_model.dart';
import 'api_client.dart';

/// Authentication (mirrors `POST /auth/register` and `POST /auth/login`).
class AuthService {
  AuthService({ApiClient? client}) : _api = client ?? ApiClient.instance;

  final ApiClient _api;

  /// Register a new user with name, phone and password. The backend returns a
  /// persistent `access_token` stored on [ApiClient] and sent as
  /// `Authorization: Bearer` on every subsequent request.
  Future<BusinessModel> registerBusiness({
    required String name,
    required String ownerPhone,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post('/auth/register', data: {
        'name': name,
        'business_name': name,
        'owner_phone': ownerPhone,
        'password': password,
      });
      return _handleAuth(res);
    } on DioException catch (e) {
      throw apiErrorMessage(e);
    }
  }

  /// Login with phone + password. Rotates the access token server-side.
  Future<BusinessModel> login({
    required String ownerPhone,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post('/auth/login', data: {
        'owner_phone': ownerPhone,
        'password': password,
      });
      return _handleAuth(res);
    } on DioException catch (e) {
      throw apiErrorMessage(e);
    }
  }

  /// Returns the currently authenticated business + its server-side plan.
  /// Used by the session's periodic re-sync so the plan stays up to date.
  Future<BusinessModel> me() async {
    try {
      final res = await _api.dio.get('/auth/me');
      return BusinessModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw apiErrorMessage(e);
    }
  }

  /// Requests an OTP for the given phone. The backend sends it as a WhatsApp
  /// self-message through the business's connected instance.
  Future<void> forgotPassword({required String ownerPhone}) async {
    try {
      await _api.dio.post('/auth/forgot-password', data: {
        'phone': ownerPhone,
      });
    } on DioException catch (e) {
      throw apiErrorMessage(e);
    }
  }

  /// Validates the OTP for the given phone. Throws on invalid/expired codes.
  Future<void> verifyOtp({
    required String ownerPhone,
    required String otp,
  }) async {
    try {
      await _api.dio.post('/auth/verify-otp', data: {
        'phone': ownerPhone,
        'otp': otp,
      });
    } on DioException catch (e) {
      throw apiErrorMessage(e);
    }
  }

  /// Resets the password and returns the (already authenticated) business, so
  /// the app can auto-login straight into the dashboard.
  Future<BusinessModel> resetPassword({
    required String ownerPhone,
    required String newPassword,
  }) async {
    try {
      final res = await _api.dio.post('/auth/reset-password', data: {
        'phone': ownerPhone,
        'new_password': newPassword,
      });
      return _handleAuth(res);
    } on DioException catch (e) {
      throw apiErrorMessage(e);
    }
  }

  /// Liveness probe: any HTTP response (even 401/404/500) proves the backend
  /// is reachable; only connection/timeout/cancel errors mean it is down.
  Future<bool> isBackendReachable() async {
    try {
      await _api.dio.get('/auth/me', options: Options(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 8),
      ));
      return true;
    } on DioException catch (e) {
      return e.response != null;
    } catch (_) {
      return false;
    }
  }

  BusinessModel _handleAuth(Response<dynamic> res) {
    final business = BusinessModel.fromJson(res.data as Map<String, dynamic>);
    if (business.accessToken != null && business.accessToken!.isNotEmpty) {
      _api.authToken = business.accessToken;
    }
    return business;
  }
}
