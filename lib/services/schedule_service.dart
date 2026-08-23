import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/constants/post_channel.dart';
import '../core/constants/post_media_type.dart';
import '../core/constants/post_repeat.dart';
import '../core/constants/post_status.dart';
import '../models/post_schedule_model.dart';
import 'api_client.dart';

/// Scheduling service — mirrors `routes/schedule.js` (`/api/posts`).
class ScheduleService {
  ScheduleService({ApiClient? client}) : _api = client ?? ApiClient.instance;

  final ApiClient _api;

  /// Creates a scheduled post. Text statuses need no file; image/video upload
  /// the media (multipart `image`) alongside `content`, `type`,
  /// `scheduled_time`, and optional `recurrenceRule` JSON.
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
    try {
      final form = FormData.fromMap({
        'content': caption,
        'scheduled_time': scheduledTime.toUtc().toIso8601String(),
        'type': type.name,
        if (recurrenceRule != null)
          'recurrenceRule': recurrenceRule
        else
          'repeat': repeat.apiValue,
        if (type == PostMediaType.text && backgroundColor != null) 'backgroundColor': backgroundColor,
        if (type == PostMediaType.text && font != null) 'font': font,
        if (type != PostMediaType.text && imageBytes != null)
          'image': MultipartFile.fromBytes(
            imageBytes,
            filename: imageName ?? _defaultName(type),
            contentType: DioMediaType(_mediaTypeOf(type), _ext(imageName ?? _defaultName(type))),
          ),
      });
      final res = await _api.dio.post('/posts', data: form);
      return PostScheduleModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Lists scheduled posts, optionally filtered by status.
  Future<List<PostScheduleModel>> listPosts({PostStatus? status, int? businessId}) async {
    try {
      final res = await _api.dio.get('/posts', queryParameters: {
        'status': ?status?.apiValue,
      });
      return _parseList(res.data);
    } on DioException {
      rethrow;
    }
  }

  /// Retries a failed post.
  Future<PostScheduleModel> retryPost(int postId) async {
    try {
      final res = await _api.dio.post('/posts/$postId/retry');
      return PostScheduleModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Fetches a single post (refreshes viewer count live on the backend).
  Future<PostScheduleModel> getPost(int postId) async {
    try {
      final res = await _api.dio.get('/posts/$postId');
      return PostScheduleModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Updates a pending post's caption / time and optionally its image.
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
    try {
      final form = FormData.fromMap({
        'content': caption,
        'scheduled_time': scheduledTime.toUtc().toIso8601String(),
        if (recurrenceRule != null)
          'recurrenceRule': recurrenceRule
        else
          'repeat': repeat.apiValue,
        'backgroundColor': ?backgroundColor,
        'font': ?font,
        if (imageBytes != null)
          'image': MultipartFile.fromBytes(
            imageBytes,
            filename: imageName ?? _defaultName(type),
            contentType: DioMediaType(_mediaTypeOf(type), _ext(imageName ?? _defaultName(type))),
          ),
      });
      final res = await _api.dio.put('/posts/$postId', data: form);
      return PostScheduleModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Deletes a post (cancels pending, or deletes a live status when sent).
  Future<void> deletePost(int postId) async {
    try {
      await _api.dio.delete('/posts/$postId');
    } on DioException {
      rethrow;
    }
  }

  List<PostScheduleModel> _parseList(dynamic data) {
    List<dynamic> items;
    if (data is Map && data['posts'] is List) {
      items = data['posts'] as List;
    } else if (data is Map && data['data'] is List) {
      items = data['data'] as List;
    } else if (data is List) {
      items = data;
    } else {
      items = const [];
    }
    return items
        .whereType<Map>()
        .map((e) => PostScheduleModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static String _ext(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return 'jpg';
    return name.substring(dot + 1).toLowerCase();
  }

  static String _mediaTypeOf(PostMediaType type) => switch (type) {
        PostMediaType.video => 'video',
        PostMediaType.text => 'image',
        PostMediaType.image => 'image',
      };

  static String _defaultName(PostMediaType type) => switch (type) {
        PostMediaType.video => 'video.mp4',
        PostMediaType.text => 'poster.webp',
        PostMediaType.image => 'poster.webp',
      };
}