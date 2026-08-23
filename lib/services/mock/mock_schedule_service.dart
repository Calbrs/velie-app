import 'dart:typed_data';

import '../../core/constants/post_channel.dart';
import '../../core/constants/post_media_type.dart';
import '../../core/constants/post_status.dart';
import '../../models/post_schedule_model.dart';
import '../../core/constants/post_repeat.dart';
import '../api_client.dart';
import '../schedule_service.dart';
import 'mock_data_store.dart';

/// Simulated scheduling service backed by an in-memory list, persisted to
/// SharedPreferences (paths only) + disk files for media, so posts and their
/// text-status images survive app restarts.
/// Pending posts whose scheduled time has passed are "dispatched" (→ sent) on
/// the next list, mimicking the backend cron.
class MockScheduleService extends ScheduleService {
  MockScheduleService() : super(client: ApiClient.instance) {
    _hydrated = _init();
  }

  late final Future<void> _hydrated;

  final MockDataStore _store = MockDataStore.instance;

  Future<void> _init() async {
    await _store.loadPosts();
    if (_store.posts.isEmpty) _seed();
  }

  Future<void> _ensureLoaded() => _hydrated;

  void _seed() {
    final now = DateTime.now();
    _store.posts.addAll([
      PostScheduleModel(
        id: _store.nextPostId++,
        caption: 'Ofa kubwa! Leo tu: punguzo 20% kwenye bidhaa zote.',
        channel: PostChannel.waStatus,
        scheduledTime: now.subtract(const Duration(minutes: 10)),
        status: PostStatus.sent,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      PostScheduleModel(
        id: _store.nextPostId++,
        caption: 'Bidhaa mpya imefika dukani! Karibu kuangalia.',
        channel: PostChannel.waGroup,
        scheduledTime: now.add(const Duration(hours: 1)),
        status: PostStatus.pending,
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
      PostScheduleModel(
        id: _store.nextPostId++,
        caption: 'Tukumbushane: huduma zote zinapatikana Jumamosi.',
        channel: PostChannel.waStatus,
        scheduledTime: now.subtract(const Duration(hours: 5)),
        status: PostStatus.failed,
        retries: 2,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      PostScheduleModel(
        id: _store.nextPostId++,
        caption: 'Shukrani kwa wateja wote! Endelea kuwa nasi.',
        channel: PostChannel.waStatus,
        scheduledTime: now.subtract(const Duration(days: 1)),
        status: PostStatus.sent,
        createdAt: now.subtract(const Duration(days: 1, hours: 1)),
      ),
    ]);
  }

  @override
  Future<PostScheduleModel> createPost({
    required String caption,
    PostMediaType type = PostMediaType.image,
    String? backgroundColor,
    int? font,
    Uint8List? imageBytes,
    String? imageName,
    required PostChannel channel,
    required DateTime scheduledTime,
    PostRepeat repeat = PostRepeat.once,
    Map<String, dynamic>? recurrenceRule,
    int? businessId,
  }) async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 900));
    final localMediaPath = imageBytes == null
        ? null
        : await _store.persistMedia(imageBytes);
    final post = PostScheduleModel(
      id: _store.nextPostId++,
      caption: caption,
      localMediaPath: localMediaPath,
      localImage: imageBytes,
      channel: channel,
      mediaType: type,
      backgroundColor: backgroundColor,
      font: font,
      scheduledTime: scheduledTime,
      status: PostStatus.pending,
      createdAt: DateTime.now(),
      repeat: repeat,
    );
    _store.posts.add(post);
    await _store.savePosts();
    return post;
  }

  @override
  Future<List<PostScheduleModel>> listPosts({
    PostStatus? status,
    int? businessId,
  }) async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 500));
    _advanceDispatch();
    var result = List<PostScheduleModel>.from(_store.posts);
    if (status != null) {
      result = result.where((p) => p.status == status).toList();
    }
    return result;
  }

  @override
  Future<PostScheduleModel> retryPost(int postId) async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 700));
    final index = _store.posts.indexWhere((p) => p.id == postId);
    if (index < 0) throw 'Post haikupatikana';
    final current = _store.posts[index];
    final updated = current.copyWith(
      status: PostStatus.pending,
      retries: current.retries + 1,
      scheduledTime: DateTime.now().add(const Duration(seconds: 15)),
    );
    _store.posts[index] = updated;
    await _store.savePosts();
    return updated;
  }

  @override
  Future<PostScheduleModel> updatePost(
    int postId, {
    required String caption,
    PostMediaType type = PostMediaType.image,
    String? backgroundColor,
    int? font,
    required PostChannel channel,
    required DateTime scheduledTime,
    PostRepeat repeat = PostRepeat.once,
    Map<String, dynamic>? recurrenceRule,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 700));
    final index = _store.posts.indexWhere((p) => p.id == postId);
    if (index < 0) throw 'Post haikupatikana';
    final current = _store.posts[index];
    final localMediaPath = imageBytes == null
        ? current.localMediaPath
        : await _store.persistMedia(imageBytes);
    final updated = PostScheduleModel(
      id: current.id,
      caption: caption,
      imageUrl: current.imageUrl,
      localMediaPath: localMediaPath,
      localImage: imageBytes ?? current.localImage,
      channel: channel,
      mediaType: type,
      backgroundColor: backgroundColor,
      font: font,
      scheduledTime: scheduledTime,
      status: current.status,
      retries: current.retries,
      createdAt: current.createdAt,
      repeat: repeat,
    );
    _store.posts[index] = updated;
    await _store.savePosts();
    return updated;
  }

  @override
  Future<void> deletePost(int postId) async {
    await _ensureLoaded();
    await Future.delayed(const Duration(milliseconds: 400));
    _store.posts.removeWhere((p) => p.id == postId);
    await _store.savePosts();
  }

  void _advanceDispatch() {
    final now = DateTime.now();
    var changed = false;
    for (var i = 0; i < _store.posts.length; i++) {
      final p = _store.posts[i];
      if (p.status == PostStatus.pending &&
          p.scheduledTime != null &&
          p.scheduledTime!.isBefore(now)) {
        _store.posts[i] = p.copyWith(status: PostStatus.sent);
        changed = true;
      }
    }
    if (changed) _store.savePosts();
  }
}
