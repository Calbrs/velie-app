import 'package:dio/dio.dart';

import '../models/whatsapp_instance_model.dart';
import 'api_client.dart';

/// WhatsApp instance management via the Velie backend.
///
/// Flow (persistent workers):
///   1. `POST /admin/instances` → creates instance, backend boots Chrome worker
///      in background. Returns immediately with status `starting`.
///   2. Poll `GET /admin/instances/:id/status` — when status becomes `pending`,
///      the Chrome worker is alive and WhatsApp Web is loaded.
///   3. Frontend auto-requests pairing code (or user taps "Pata Msimbo Mpya").
///      Code is generated instantly via page.evaluate() on the alive worker.
///   4. Poll until `status == connected` (user entered code on phone).
class InstanceService {
  InstanceService({ApiClient? client}) : _api = client ?? ApiClient.instance;

  final ApiClient _api;

  /// Pairing-code refresh can still take a while if the session needs a
  /// moment to be ready — keep a generous timeout for that call.
  static final Options _pairingOptions = Options(
    connectTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  );

  /// Creates an instance and starts session warming (non-blocking).
  /// Returns quickly with status `starting` — no pairing code yet.
  Future<WhatsAppInstanceModel> createInstance() async {
    try {
      final res = await _api.dio.post('/admin/instances');
      return WhatsAppInstanceModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Requests a fresh pairing code for an existing instance (old one expires).
  Future<WhatsAppInstanceModel> refreshPairingCode({int? instanceId}) async {
    final id = instanceId ?? 0;
    if (id <= 0) throw 'Instance id inahitajika';
    try {
      final res = await _api.dio.post(
        '/admin/instances/$id/pairing-code/refresh',
        options: _pairingOptions,
      );
      return WhatsAppInstanceModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Polls the current instance status.
  Future<WhatsAppInstanceModel> fetchInstance({int? instanceId}) async {
    final id = instanceId ?? 0;
    if (id <= 0) return const WhatsAppInstanceModel.empty();
    try {
      final res = await _api.dio.get('/admin/instances/$id/status');
      return WhatsAppInstanceModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Lightweight existence check — returns the business's current instance if
  /// one exists, or `null` when there is none.
  Future<WhatsAppInstanceModel?> fetchCurrentInstance() async {
    try {
      final res = await _api.dio.get('/admin/instances/current');
      return WhatsAppInstanceModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Disconnects (logs out) the WhatsApp session for an instance.
  Future<void> disconnect({int? instanceId}) async {
    final id = instanceId ?? 0;
    if (id <= 0) return;
    try {
      await _api.dio.delete('/admin/instances/$id');
    } on DioException {
      rethrow;
    }
  }
}
