import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/business_model.dart';
import '../../models/post_schedule_model.dart';
import '../../models/whatsapp_instance_model.dart';

/// In-memory state shared by all mock services (singleton per app run).
///
/// Media "cache to store files" (text-status poster images) is persisted the
/// disk-files + SharedPreferences-metadata way: raw bytes are written to the
/// app documents directory and only the file *path* is stored in
/// SharedPreferences. On the next launch the posts are reloaded and each
/// poster's bytes are re-hydrated from disk, so images survive app restarts
/// without bloating the preferences store.
class MockDataStore {
  MockDataStore._();

  static final MockDataStore instance = MockDataStore._();

  static final Random _rand = Random();

  static const _postsKey = 'velie_mock_posts';

  BusinessModel? business;
  WhatsAppInstanceModel? whatsappInstance;
  DateTime? connectAfter;
  int instanceId = 0;
  int nextPostId = 1;
  final List<PostScheduleModel> posts = [];

  /// Mock OTP used by [MockAuthService] in the forgot-password flow.
  String? lastOtp;

  /// Loads previously-persisted posts (paths only) and re-hydrates each poster
  /// image's bytes from disk. Called once before seeding so user-created posts
  /// survive restarts instead of being re-seeded from scratch.
  Future<void> loadPosts() async {
    if (posts.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_postsKey) ?? const [];
    for (final e in raw) {
      try {
        final post = PostScheduleModel.fromPersistedJson(jsonDecode(e) as Map<String, dynamic>);
        posts.add(post);
        if (post.id + 1 > nextPostId) nextPostId = post.id + 1;
      } catch (_) {}
    }
    await _hydratePostBytes();
  }

  /// Persists the current post list to SharedPreferences (metadata/paths only
  /// — never raw bytes) and writes any new media to disk files.
  Future<void> savePosts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _postsKey,
      posts.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  /// Writes poster bytes to a docs-directory file and returns its path.
  Future<String> persistMedia(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/post_media_${DateTime.now().microsecondsSinceEpoch}');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> _hydratePostBytes() async {
    for (var i = 0; i < posts.length; i++) {
      final post = posts[i];
      if (post.localImage != null || post.localMediaPath == null) continue;
      posts[i] = post.withHydratedImage(await post.loadLocalBytes());
    }
  }

  /// Generates a pairing code in the `WXYZ-1234` shape.
  static String generatePairingCode() {
    final letters = List.generate(
      4,
      (_) => String.fromCharCode(65 + _rand.nextInt(26)),
    ).join();
    final digits = List.generate(4, (_) => _rand.nextInt(10)).join();
    return '$letters-$digits';
  }
}
