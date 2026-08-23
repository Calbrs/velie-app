import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/session/session.dart';
import '../models/whatsapp_instance_model.dart';
import '../services/instance_service.dart';

/// WhatsApp instance connection state — polls the backend which maintains
/// persistent Chrome workers per instance.
///
/// State machine (matches backend SessionManager):
///   starting → pending → pairing → connected
///                ↓
///            disconnected
///
/// Key change from old architecture:
///   - `createInstance()` returns immediately with `starting` status
///   - Backend boots a Chrome worker in background
///   - When worker reaches `pending`, frontend auto-requests pairing code
///   - Pairing code is instant (page.evaluate on alive worker)
///   - User enters code on phone → `connected`
class InstanceProvider extends ChangeNotifier {
  InstanceProvider({InstanceService? service, this.session})
      : _service = service ?? InstanceService();

  final InstanceService _service;

  final Session? session;

  static const _prefsKey = 'velie_instance';

  WhatsAppInstanceModel? _instance;
  bool _isLoading = false;
  bool _isCreating = false;
  String? _error;
  Timer? _pollTimer;
  bool _initialized = false;
  bool _hasInstance = false;

  /// Tracks when we started waiting, so the UI can show elapsed time.
  DateTime? _startedAt;

  /// Whether we hit a rate-limit error and should stop auto-retrying.
  bool _rateLimited = false;

  /// Whether we've already auto-requested pairing code for the current `pending` state.
  /// Prevents duplicate requests when poll detects `pending` multiple times.
  bool _pairingCodeRequested = false;

  WhatsAppInstanceModel? get instance => _instance;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get error => _error;
  bool get isInitialized => _initialized;

  bool get isConnected => _instance?.isConnected ?? false;
  bool get isDisconnected => _instance?.isDisconnected ?? false;
  bool get isStarting => _instance?.isStarting ?? false;
  bool get isPending => _instance?.isPending ?? false;
  bool get isPairing => _instance?.isPairing ?? false;
  bool get hasPairingCode => _instance?.hasPairingCode ?? false;
  bool get isRateLimited => _rateLimited;
  String? get pairingCode => _instance?.pairingCode;

  bool get hasInstance => _hasInstance;

  Duration? get elapsed => _startedAt != null ? DateTime.now().difference(_startedAt!) : null;

  // ── Initialization ──────────────────────────────────────────────────

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('${_prefsKey}_id');
    if (id != null && id > 0) {
      _instance = WhatsAppInstanceModel(id: id, status: 'connecting');
      _hasInstance = true;
    } else {
      _instance = const WhatsAppInstanceModel.empty();
      _hasInstance = false;
    }
    _initialized = true;
    notifyListeners();

    if (id != null && id > 0) {
      await _fetch();
    }
  }

  Future<bool> checkHasInstance() async {
    if (_hasInstance) return true;
    try {
      final found = await _service.fetchCurrentInstance();
      if (found != null && found.id > 0) {
        _instance = found;
        _hasInstance = true;
        await _persistId();
        _syncRelink();
        _startPolling();
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ── Create instance ─────────────────────────────────────────────────

  /// Creates an instance. Returns quickly with status `starting`.
  /// The backend boots a Chrome worker in the background.
  Future<void> createInstance() async {
    _isCreating = true;
    _error = null;
    _rateLimited = false;
    _pairingCodeRequested = false;
    _startedAt = DateTime.now();
    _clearStaleCode();
    notifyListeners();
    try {
      _instance = await _service.createInstance();
      _hasInstance = true;
      await _persistId();
      _syncRelink();
      _startPolling();
    } catch (e) {
      _error = '$e';
      rethrow;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // ── Pairing code ────────────────────────────────────────────────────

  /// Requests a fresh pairing code. Backend finds the alive worker and
  /// calls page.evaluate() — should be fast (no Chrome restart).
  Future<void> refreshPairingCode() async {
    _isLoading = true;
    _error = null;
    _rateLimited = false;
    _clearStaleCode();
    notifyListeners();
    try {
      _instance = await _service.refreshPairingCode(instanceId: _instance?.id);
      _hasInstance = true;
      await _persistId();
      _syncRelink();
      _pairingCodeRequested = true;
      _startPolling();
    } catch (e) {
      _error = '$e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Makes sure a pairing code is available — refreshes an existing instance
  /// or creates a brand new one, then starts polling for `connected`.
  Future<void> ensurePairingCode() async {
    _isLoading = true;
    _error = null;
    _rateLimited = false;
    _pairingCodeRequested = false;
    _startedAt = DateTime.now();
    notifyListeners();
    try {
      if (_instance != null && _instance!.id > 0) {
        try {
          _instance = await _service.refreshPairingCode(instanceId: _instance!.id);
          _pairingCodeRequested = true;
        } catch (_) {
          _instance = await _service.createInstance();
          _pairingCodeRequested = false;
        }
      } else {
        _instance = await _service.createInstance();
        _pairingCodeRequested = false;
      }
      _hasInstance = true;
      await _persistId();
      _syncRelink();
      _startPolling();
    } catch (e) {
      _error = '$e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Polling ─────────────────────────────────────────────────────────

  void _clearStaleCode() {
    final current = _instance;
    if (current == null) return;
    _instance = WhatsAppInstanceModel(
      id: current.id,
      status: current.status,
      phone: current.phone,
      connectedAt: current.connectedAt,
      pairingCode: null,
    );
  }

  Future<void> _fetch() async {
    _isLoading = true;
    notifyListeners();
    try {
      _instance = await _service.fetchInstance(instanceId: _instance?.id);
      if (_instance != null && _instance!.id > 0) {
        _hasInstance = true;
      }
      _syncRelink();
      _startPolling();
    } catch (e) {
      _error = '$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startPolling() {
    if (_pollTimer != null) return;
    final interval = _pollInterval;
    _pollTimer = Timer.periodic(interval, (_) => _poll());
  }

  void _startPolling() {
    startPolling();
  }

  void stopPolling() {
    _stopPolling();
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Poll interval adapts to current state:
  ///   - starting: 1s (fast — worker is booting)
  ///   - pending/pairing: 2s (worker alive, code generation is fast)
  ///   - connected: 30s (slow — just watching for disconnect)
  Duration get _pollInterval {
    if (isConnected) return AppConstants.instanceConnectedPollInterval;
    if (isStarting) return const Duration(seconds: 1);
    return const Duration(seconds: 2); // pending or pairing
  }

  Future<void> _poll() async {
    if (_instance == null) {
      _stopPolling();
      return;
    }
    try {
      final fresh = await _service.fetchInstance(instanceId: _instance!.id);
      final wasConnected = isConnected;
      final wasStarting = isStarting;

      _instance = fresh;
      if (fresh.id > 0) {
        _hasInstance = true;
      }
      _syncRelink();

      // Adapt the poll cadence to the current connection state.
      if (isConnected != wasConnected || isStarting != wasStarting) {
        if (isConnected) {
          _startedAt = null;
          _pairingCodeRequested = false;
        }
        _stopPolling();
        startPolling();
      }

      // Auto-request pairing code when worker reaches `pending` (alive, ready).
      // The worker is alive — code generation is instant via page.evaluate().
      if (isPending && !_pairingCodeRequested && !_isLoading) {
        _pairingCodeRequested = true;
        _autoRequestPairingCode();
      }

      notifyListeners();
    } catch (_) {
      // Transient network blip — keep polling.
    }
  }

  /// Fire-and-forget pairing code request when worker becomes ready.
  /// Errors are surfaced through the instance model / error state.
  Future<void> _autoRequestPairingCode() async {
    if (_instance == null || _instance!.id <= 0) return;
    try {
      _instance = await _service.refreshPairingCode(instanceId: _instance!.id);
      _hasInstance = true;
      await _persistId();
      notifyListeners();
    } catch (e) {
      // Don't set _rateLimited here — the user can manually retry.
      // Just log and let the poll continue.
      debugPrint('[InstanceProvider] auto pairing-code request failed: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await _service.disconnect(instanceId: _instance?.id);
    } catch (_) {}
    _stopPolling();
    _instance = const WhatsAppInstanceModel.empty();
    _hasInstance = false;
    _startedAt = null;
    _pairingCodeRequested = false;
    _syncRelink();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_prefsKey}_id');
    notifyListeners();
  }

  void resetSession() {
    _stopPolling();
    _instance = const WhatsAppInstanceModel.empty();
    _hasInstance = false;
    _startedAt = null;
    _pairingCodeRequested = false;
    _syncRelink();
    _initialized = true;
    notifyListeners();
  }

  void _syncRelink() {
    final session = this.session;
    if (session == null) return;
    final needsRelink = _hasInstance &&
        _instance != null &&
        _instance!.isDisconnected;
    session.setRelinkRequired(needsRelink);
  }

  Future<void> _persistId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_prefsKey}_id', _instance?.id ?? 0);
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
