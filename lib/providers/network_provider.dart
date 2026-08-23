import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Watches the device's connectivity state and exposes whether the app is
/// offline. Drives the global offline banner/drawer across the whole app.
class NetworkProvider extends ChangeNotifier {
  NetworkProvider() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  Future<void> _init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _apply(results);
      _sub = _connectivity.onConnectivityChanged.listen(_apply);
    } catch (_) {
      // Connectivity plugin unavailable — default to online so the app is not
      // permanently stuck behind the offline banner.
      _isOffline = false;
    }
  }

  void _apply(List<ConnectivityResult> results) {
    final offline = results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);
    if (offline != _isOffline) {
      _isOffline = offline;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}