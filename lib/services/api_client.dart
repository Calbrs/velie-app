import 'package:dio/dio.dart';

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

/// Converts a [DioException] into a human-friendly Swahili message.
String apiErrorMessage(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Muda umeisha — angalia mtandao wako';
    case DioExceptionType.connectionError:
      return 'Haiwezi kuunganishwa na seva';
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode;
      if (status == 401) return 'Idhini imekataliwa (401)';
      if (status == 404) return 'Hakuna maelezo yaliyopatikana (404)';
      final msg = _extractMessage(e.response?.data);
      return msg ?? 'Seva imerudisha hitilafu ($status)';
    case DioExceptionType.cancel:
      return 'Ombi limeghairiwa';
    default:
      return 'Hitilafu isiyojulikana';
  }
}

String? _extractMessage(dynamic data) {
  if (data is Map) {
    final m = data['message'] ?? data['error'] ?? data['detail'];
    if (m != null) return '$m';
  }
  return null;
}
