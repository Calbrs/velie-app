import 'dart:io';
import 'dart:typed_data';

import '../core/constants/app_constants.dart';
import '../core/constants/post_channel.dart';
import '../core/constants/post_media_type.dart';
import '../core/constants/post_status.dart';
import '../core/constants/post_repeat.dart';

/// Mirrors the `posts_schedule` table (backend `/api/posts`).
class PostScheduleModel {
  final int id;
  final String caption;
  final String? imageUrl;

  /// Persisted file path of the poster image bytes (used in simulation mode,
  /// where there is no server URL to render from). The bytes on disk outlive
  /// app restarts; only this path is stored in SharedPreferences metadata.
  final String? localMediaPath;

  /// Bytes of the poster image held in memory for rendering, hydrated from
  /// [localMediaPath] (or set directly when a post is first created).
  final Uint8List? localImage;

  final PostChannel channel;
  final PostMediaType mediaType;
  final String? backgroundColor;
  final int? font;
  final DateTime? scheduledTime;
  final PostStatus status;
  final int retries;
  final int? viewerCount;
  final DateTime? createdAt;
  final DateTime? publishedAt;
  final PostRepeat repeat;
  final Map<String, dynamic>? recurrenceRule;
  final int executionsCount;

  const PostScheduleModel({
    required this.id,
    required this.caption,
    this.imageUrl,
    this.localMediaPath,
    this.localImage,
    required this.channel,
    this.mediaType = PostMediaType.image,
    this.backgroundColor,
    this.font,
    this.scheduledTime,
    required this.status,
    this.retries = 0,
    this.viewerCount,
    this.createdAt,
    this.publishedAt,
    this.repeat = PostRepeat.once,
    this.recurrenceRule,
    this.executionsCount = 0,
  });

  bool get isPending => status == PostStatus.pending;
  bool get isFailed => status == PostStatus.failed;
  bool get isDeleted => status == PostStatus.deleted;
  bool get isText => mediaType == PostMediaType.text;

  String get recurrenceSummary {
    final rule = recurrenceRule;
    if (rule == null) return repeat.label;
    final type = rule['type']?.toString();
    final interval = rule['interval'] ?? 1;
    if (type == 'daily') return interval > 1 ? 'Every $interval days' : 'Every day';
    if (type == 'weekly') {
      final days = rule['days'];
      if (days is List && days.isNotEmpty) {
        final labels = days.map((d) => d.toString().substring(0, 1).toUpperCase() + d.toString().substring(1)).join(', ');
        return interval > 1 ? 'Every $interval weeks on $labels' : 'Every week on $labels';
      }
      return interval > 1 ? 'Every $interval weeks' : 'Every week';
    }
    if (type == 'monthly') return interval > 1 ? 'Every $interval months' : 'Every month';
    if (type == 'custom') {
      if (interval > 1) return 'Every $interval days';
      return 'Custom';
    }
    return repeat.label;
  }

  factory PostScheduleModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    return PostScheduleModel(
      id: int.tryParse('${data['id'] ?? data['post_id'] ?? 0}') ?? 0,
      caption: '${data['content'] ?? data['caption'] ?? ''}',
      imageUrl: AppConstants.resolveMediaUrl(
        data['media_url']?.toString() ?? data['image_url']?.toString(),
      ),
      channel: PostChannel.waStatus,
      mediaType: _typeFromBackend('${data['type'] ?? ''}'),
      backgroundColor: data['backgroundColor']?.toString() ?? data['background_color']?.toString(),
      font: int.tryParse('${data['font'] ?? ''}'),
      scheduledTime: DateTime.tryParse('${data['scheduled_time'] ?? data['scheduledAt'] ?? ''}'),
      status: PostStatus.fromApi('${data['status'] ?? ''}'),
      retries: int.tryParse('${data['retries'] ?? 0}') ?? 0,
      viewerCount: int.tryParse('${data['viewer_count'] ?? ''}'),
      createdAt: DateTime.tryParse('${data['created_at'] ?? data['createdAt'] ?? ''}'),
      publishedAt: DateTime.tryParse('${data['published_at'] ?? data['publishedAt'] ?? ''}'),
      repeat: PostRepeat.fromApi('${data['repeat'] ?? ''}'),
      recurrenceRule: data['recurrence_rule'] is Map
          ? Map<String, dynamic>.from(data['recurrence_rule'] as Map)
          : null,
      executionsCount: int.tryParse('${data['executions_count'] ?? 0}') ?? 0,
    );
  }

  static PostMediaType _typeFromBackend(String type) {
    switch (type) {
      case 'text':
        return PostMediaType.text;
      case 'video':
        return PostMediaType.video;
      default:
        return PostMediaType.image;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': caption,
        'media_url': imageUrl,
        'local_media_path': localMediaPath,
        'type': mediaType.name,
        'channel': channel.name,
        'background_color': backgroundColor,
        'font': font,
        'scheduled_time': scheduledTime?.toIso8601String(),
        'status': status.apiValue,
        'retries': retries,
        'viewer_count': viewerCount,
        'created_at': createdAt?.toIso8601String(),
        'published_at': publishedAt?.toIso8601String(),
        'repeat': repeat.apiValue,
        'recurrence_rule': recurrenceRule,
        'executions_count': executionsCount,
      };

  /// Rebuilds a post from the local persistence format written by [toJson]
  /// (used by the mock store to survive app restarts; holds only path metadata,
  /// never raw bytes).
  factory PostScheduleModel.fromPersistedJson(Map<String, dynamic> json) {
    return PostScheduleModel(
      id: (json['id'] ?? 0) as int,
      caption: '${json['content'] ?? ''}',
      imageUrl: json['media_url'] as String?,
      localMediaPath: json['local_media_path'] as String?,
      channel: PostChannel.values.asNameMap()[json['channel']] ?? PostChannel.waStatus,
      mediaType: PostMediaType.values.asNameMap()[json['type']] ?? PostMediaType.image,
      backgroundColor: json['background_color'] as String?,
      font: json['font'] as int?,
      scheduledTime: DateTime.tryParse('${json['scheduled_time'] ?? ''}'),
      status: PostStatus.fromApi('${json['status'] ?? ''}'),
      retries: (json['retries'] ?? 0) as int,
      viewerCount: json['viewer_count'] as int?,
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
      publishedAt: DateTime.tryParse('${json['published_at'] ?? ''}'),
      repeat: PostRepeat.fromApi('${json['repeat'] ?? ''}'),
      recurrenceRule: json['recurrence_rule'] is Map
          ? Map<String, dynamic>.from(json['recurrence_rule'] as Map)
          : null,
      executionsCount: (json['executions_count'] ?? 0) as int,
    );
  }

  /// Returns a copy with fresh poster bytes (and optional new path) hydrated
  /// from disk after a restart.
  PostScheduleModel withHydratedImage(Uint8List? bytes) {
    return PostScheduleModel(
      id: id,
      caption: caption,
      imageUrl: imageUrl,
      localMediaPath: localMediaPath,
      localImage: bytes ?? localImage,
      channel: channel,
      mediaType: mediaType,
      backgroundColor: backgroundColor,
      font: font,
      scheduledTime: scheduledTime,
      status: status,
      retries: retries,
      viewerCount: viewerCount,
      createdAt: createdAt,
      publishedAt: publishedAt,
      repeat: repeat,
      recurrenceRule: recurrenceRule,
      executionsCount: executionsCount,
    );
  }

  /// Reads the persisted poster image bytes from disk (used to hydrate
  /// `localImage` after a restart, where in-memory bytes no longer exist).
  Future<Uint8List?> loadLocalBytes() async {
    final path = localMediaPath;
    if (path == null) return null;
    try {
      return await File(path).readAsBytes();
    } catch (_) {
      return null;
    }
  }

  PostScheduleModel copyWith({
    PostStatus? status,
    int? retries,
    DateTime? scheduledTime,
    Uint8List? localImage,
  }) {
    return PostScheduleModel(
      id: id,
      caption: caption,
      imageUrl: imageUrl,
      localMediaPath: localMediaPath,
      localImage: localImage ?? this.localImage,
      channel: channel,
      mediaType: mediaType,
      backgroundColor: backgroundColor,
      font: font,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      retries: retries ?? this.retries,
      createdAt: createdAt,
      repeat: repeat,
      recurrenceRule: recurrenceRule,
      executionsCount: executionsCount,
    );
  }
}
