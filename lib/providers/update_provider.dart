import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProvider extends ChangeNotifier {
  static const _versionUrl =
      'https://objectstorage.af-johannesburg-1.oraclecloud.com/n/axtaanhnsggb/b/velie-releases/o/version.json';
  static const _apkName = 'velie_update.apk';

  bool _isDownloading = false;
  bool _isReady = false;
  double _progress = 0.0;
  String? _latestVersion;

  bool get isDownloading => _isDownloading;
  bool get isReady => _isReady;
  double get progress => _progress;
  String? get latestVersion => _latestVersion;

  Future<void> checkForUpdateAndDownload() async {
    // Prevent multiple concurrent checks/downloads
    if (_isDownloading) return;

    try {
      final dio = Dio();
      final res = await dio.get(_versionUrl);

      if (res.statusCode == 200 && res.data != null) {
        Map<String, dynamic> data;
        if (res.data is String) {
          data = jsonDecode(res.data as String) as Map<String, dynamic>;
        } else {
          data = res.data as Map<String, dynamic>;
        }

        final remoteVersion = data['version'] as String;
        final remoteApkUrl = data['apkUrl'] as String;

        final packageInfo = await PackageInfo.fromPlatform();
        final localVersion = packageInfo.version;

        if (_isVersionGreater(remoteVersion, localVersion)) {
          final prefs = await SharedPreferences.getInstance();
          final existingVersion = prefs.getString('ready_update_apk_version');

          if (existingVersion == remoteVersion) {
            final path = prefs.getString('ready_update_apk_path');
            if (path != null && await File(path).exists()) {
              _isReady = true;
              _latestVersion = remoteVersion;
              notifyListeners();
              return;
            }
          }

          // Start downloading
          _isDownloading = true;
          _latestVersion = remoteVersion;
          _progress = 0.0;
          notifyListeners();

          // Use external files directory — accessible by Android PackageInstaller
          Directory dir;
          try {
            dir = (await getExternalStorageDirectory())!;
          } catch (_) {
            dir = await getTemporaryDirectory();
          }
          final savePath = '${dir.path}/$_apkName';

          await dio.download(
            remoteApkUrl,
            savePath,
            onReceiveProgress: (rec, total) {
              if (total != -1) {
                _progress = rec / total;
                notifyListeners();
              }
            },
          );

          // Mark as ready
          await prefs.setString('ready_update_apk_path', savePath);
          await prefs.setString('ready_update_apk_version', remoteVersion);
          await prefs.setString('ready_update_display_version', remoteVersion);

          _isDownloading = false;
          _isReady = true;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Background update check failed: $e');
      _isDownloading = false;
      notifyListeners();
    }
  }

  Future<bool> checkIsReadyInitially() async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedApkPath = prefs.getString('ready_update_apk_path');
    final downloadedApkVersion = prefs.getString('ready_update_apk_version');

    if (downloadedApkPath != null && downloadedApkVersion != null) {
      final file = File(downloadedApkPath);

      if (await file.exists()) {
        final packageInfo = await PackageInfo.fromPlatform();
        final localVersion = packageInfo.version;

        if (_isVersionGreater(downloadedApkVersion, localVersion)) {
          _isReady = true;
          _latestVersion = prefs.getString('ready_update_display_version');
          notifyListeners();
          return true;
        } else {
          try {
            await file.delete();
            await prefs.remove('ready_update_apk_path');
            await prefs.remove('ready_update_apk_version');
            await prefs.remove('ready_update_display_version');
          } catch (_) {}
        }
      }
    }
    return false;
  }

  bool _isVersionGreater(String remote, String local) {
    try {
      final v1 = remote.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final v2 = local.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (var i = 0; i < 3; i++) {
        final n1 = i < v1.length ? v1[i] : 0;
        final n2 = i < v2.length ? v2[i] : 0;
        if (n1 > n2) return true;
        if (n1 < n2) return false;
      }
    } catch (_) {}
    return false;
  }

  static Future<String?> getReadyApkPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ready_update_apk_path');
  }

  static Future<String?> getReadyDisplayVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ready_update_display_version');
  }

  static Future<void> clearReadyUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('ready_update_apk_path');

    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {}
    }

    await prefs.remove('ready_update_apk_path');
    await prefs.remove('ready_update_apk_version');
    await prefs.remove('ready_update_display_version');
  }
}