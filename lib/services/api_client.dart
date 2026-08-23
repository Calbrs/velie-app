import 'package:dio/dio.dart';
import 'package:velie_app/l10n/app_localizations.dart';

import '../core/constants/app_constants.dart';

/// Thin Dio wrapper with base URL and timeouts.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = authToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Dio get dio => _dio;

  /// Authorization token applied on every request (set after login/register).
  String? authToken;
}

/// Converts any error into a human-friendly localized message.
String apiErrorMessage(Object e, AppLocalizations l10n) {
  if (e is DioException) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return l10n.apiErrorTimeout;
      case DioExceptionType.connectionError:
        return l10n.apiErrorConnectionFailed;
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) return l10n.apiErrorUnauthorized;
        if (status == 404) return l10n.apiErrorNotFound;
        final msg = _extractMessage(e.response?.data);
        return msg ?? l10n.apiErrorServer(status?.toString() ?? 'unknown');
      case DioExceptionType.cancel:
        return l10n.apiErrorCancelled;
      default:
        return l10n.errorUnknown;
    }
  }
  return e.toString();
}

String? _extractMessage(dynamic data) {
  if (data is Map) {
    final m = data['message'] ?? data['error'] ?? data['detail'];
    if (m != null) return '$m';
  }
  return null;
}
