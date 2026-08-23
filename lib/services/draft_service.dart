import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/post_channel.dart';
import '../core/constants/post_media_type.dart';
import '../core/constants/post_repeat.dart';
import 'api_client.dart';

/// One image inside a multi-image draft, with its own independent caption.
class LocalDraftImage {
  final String? localMediaPath;
  final String? imageName;
  final String caption;

  const LocalDraftImage({
    this.localMediaPath,
    this.imageName,
    required this.caption,
  });

  Map<String, dynamic> toJson() => {
    'local_media_path': localMediaPath,
    'image_name': imageName,
    'caption': caption,
  };

  factory LocalDraftImage.fromJson(Map<String, dynamic> json) =>
      LocalDraftImage(
        localMediaPath: json['local_media_path'] as String?,
        imageName: json['image_name'] as String?,
        caption: '${json['caption'] ?? ''}',
      );
}

/// In-memory image bytes destined for a draft (used only when saving).
class DraftImageBytes {
  final Uint8List bytes;
  final String name;
  final String caption;

  const DraftImageBytes({
    required this.bytes,
    required this.name,
    this.caption = '',
  });
}

/// A locally-saved draft (image bytes + caption + channel + time).
///
/// The draft *identity* is created online ([serverId]) and scoped to the owning
/// account ([accountId]); content (media bytes, caption, edits) is stored
/// locally. Drafts whose server id doesn't belong to the logged-in account are
/// never shown.
class LocalDraft {
  /// Local identity used for dedup / thumbnail caching. Equals [serverId] once
  /// the draft has been created online, otherwise a local session token.
  final int id;

  /// The online-created draft id (per account). Null while offline.
  final int? serverId;

  /// The business (account) that owns this draft.
  final int? accountId;
  final String? localMediaPath;
  final String? imageName;
  final String caption;
  final List<LocalDraftImage> images;
  final PostChannel channel;
  final PostMediaType mediaType;
  final String? backgroundColor;
  final int? font;
  final DateTime? scheduledTime;
  final PostRepeat repeat;
  final DateTime createdAt;

  // Video Editing State
  final double? trimStart;
  final double? trimEnd;
  final String? musicFilePath;
  final String? musicFileName;
  final int? musicId;
  final int? audioStartOffsetMs;
  final int? audioDurationMs;
  final double? originalVolume;
  final double? musicVolume;
  final String? watermarkImagePath;
  final String?
  textOverlaysJson; // We store it as a JSON string array of VideoTextOverlay
  final String?
  watermarkTransformJson; // {"dx":..,"dy":..,"scale":..} preview position/size

  const LocalDraft({
    required this.id,
    this.serverId,
    this.accountId,
    this.localMediaPath,
    this.imageName,
    required this.caption,
    this.images = const [],
    required this.channel,
    this.mediaType = PostMediaType.image,
    this.backgroundColor,
    this.font,
    this.scheduledTime,
    this.repeat = PostRepeat.once,
    required this.createdAt,
    this.trimStart,
    this.trimEnd,
    this.musicFilePath,
    this.musicFileName,
    this.musicId,
    this.audioStartOffsetMs,
    this.audioDurationMs,
    this.originalVolume,
    this.musicVolume,
    this.watermarkImagePath,
    this.textOverlaysJson,
    this.watermarkTransformJson,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'server_id': serverId,
    'account_id': accountId,
    'local_media_path': localMediaPath,
    'image_name': imageName,
    'caption': caption,
    'images': images.map((e) => e.toJson()).toList(),
    'channel': channel.name,
    'media_type': mediaType.name,
    'background_color': backgroundColor,
    'font': font,
    'scheduled_time': scheduledTime?.toIso8601String(),
    'repeat': repeat.apiValue,
    'created_at': createdAt.toIso8601String(),
    'trim_start': trimStart,
    'trim_end': trimEnd,
    'music_file_path': musicFilePath,
    'music_file_name': musicFileName,
    'music_id': musicId,
    'audio_start_offset_ms': audioStartOffsetMs,
    'audio_duration_ms': audioDurationMs,
    'original_volume': originalVolume,
    'music_volume': musicVolume,
    'watermark_image_path': watermarkImagePath,
    'text_overlays_json': textOverlaysJson,
    'watermark_transform_json': watermarkTransformJson,
  };

  factory LocalDraft.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages
              .whereType<Map>()
              .map(
                (e) => LocalDraftImage.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
        : <LocalDraftImage>[];
    return LocalDraft(
      id: (json['id'] ?? 0) as int,
      serverId: (json['server_id'] as num?)?.toInt(),
      accountId: (json['account_id'] as num?)?.toInt(),
      localMediaPath: json['local_media_path'] as String?,
      imageName: json['image_name'] as String?,
      caption: '${json['caption'] ?? ''}',
      images: images,
      channel:
          PostChannel.values.asNameMap()[json['channel']] ??
          PostChannel.waStatus,
      mediaType:
          PostMediaType.values.asNameMap()[json['media_type']] ??
          PostMediaType.image,
      backgroundColor: json['background_color'] as String?,
      font: json['font'] as int?,
      scheduledTime: DateTime.tryParse('${json['scheduled_time'] ?? ''}'),
      repeat: PostRepeat.fromApi('${json['repeat'] ?? ''}'),
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? ''}') ?? DateTime.now(),
      trimStart: json['trim_start'] as double?,
      trimEnd: json['trim_end'] as double?,
      musicFilePath: json['music_file_path'] as String?,
      musicFileName: json['music_file_name'] as String?,
      musicId: json['music_id'] as int?,
      audioStartOffsetMs: json['audio_start_offset_ms'] as int?,
      audioDurationMs: json['audio_duration_ms'] as int?,
      originalVolume: json['original_volume'] as double?,
      musicVolume: json['music_volume'] as double?,
      watermarkImagePath: json['watermark_image_path'] as String?,
      textOverlaysJson: json['text_overlays_json'] as String?,
      watermarkTransformJson: json['watermark_transform_json'] as String?,
    );
  }
}

/// Persists drafts locally, keyed per account, with the draft identity created
/// online on the backend (`/drafts`). Content stays on the device.
class DraftService {
  DraftService({ApiClient? client}) : _api = client ?? ApiClient.instance;

  final ApiClient _api;

  static const _keyPrefix = 'velie_local_drafts';
  static const _autoKeyPrefix = 'velie_auto_draft';
  static const _maxDrafts = 10;

  static String _keyFor(int accountId) => '${_keyPrefix}_$accountId';
  static String _autoKeyFor(int accountId) => '${_autoKeyPrefix}_$accountId';

  // --- Server-backed draft identity (online, per account) ---

  /// Creates a draft record on the backend for this account and returns its id.
  Future<int> createServerDraft({
    required int accountId,
    required PostMediaType mediaType,
    required PostChannel channel,
  }) async {
    final res = await _api.dio.post(
      '/drafts',
      data: {'media_type': mediaType.name, 'channel': channel.apiValue},
    );
    final data = res.data as Map<String, dynamic>;
    return (data['id'] as num).toInt();
  }

  /// Updates the server draft metadata (channel / media type) so the record
  /// stays accurate for the account. Best effort.
  Future<void> touchServerDraft(
    int id, {
    PostMediaType? mediaType,
    PostChannel? channel,
  }) async {
    await _api.dio.patch(
      '/drafts/$id',
      data: {
        if (mediaType != null) 'media_type': mediaType.name,
        if (channel != null) 'channel': channel.apiValue,
      },
    );
  }

  /// Fetches the ids of every draft record owned by this account.
  Future<Set<int>> fetchServerDraftIds(int accountId) async {
    final res = await _api.dio.get('/drafts');
    final data = res.data as Map<String, dynamic>;
    final list = data['drafts'] as List? ?? const [];
    return list.whereType<Map>().map((e) => (e['id'] as num).toInt()).toSet();
  }

  /// Deletes the account's server draft record. Best effort.
  Future<void> deleteServerDraft(int id) async {
    try {
      await _api.dio.delete('/drafts/$id');
    } on DioException {
      // Local removal is what we control; server cleanup is best effort.
    }
  }

  // --- Local content (per account) ---

  /// All local drafts owned by this account, newest first.
  Future<List<LocalDraft>> list(int accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyFor(accountId)) ?? const [];
    return raw
        .map((e) {
          try {
            return LocalDraft.fromJson(jsonDecode(e) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<LocalDraft>()
        .where((d) => d.accountId == accountId)
        .toList();
  }

  /// The drafts actually shown to the user: local drafts for the current
  /// account whose server id is still owned by that account. When the backend
  /// is unreachable we fall back to the account-scoped local list.
  Future<List<LocalDraft>> listForAccount(int accountId) async {
    final local = await list(accountId);
    try {
      final serverIds = await fetchServerDraftIds(accountId);
      return local
          .where((d) => d.serverId != null && serverIds.contains(d.serverId))
          .toList();
    } catch (_) {
      return local;
    }
  }

  Future<LocalDraft> save({
    int? serverId,
    int? accountId,
    Uint8List? imageBytes,
    String? imageName,
    required String caption,
    required PostChannel channel,
    PostMediaType mediaType = PostMediaType.image,
    String? backgroundColor,
    int? font,
    DateTime? scheduledTime,
    PostRepeat repeat = PostRepeat.once,
    double? trimStart,
    double? trimEnd,
    String? musicFilePath,
    String? musicFileName,
    int? musicId,
    int? audioStartOffsetMs,
    int? audioDurationMs,
    double? originalVolume,
    double? musicVolume,
    String? watermarkImagePath,
    String? textOverlaysJson,
    String? watermarkTransformJson,
  }) async {
    final account = accountId;
    if (account == null) throw StateError('Draft inahitaji akaunti');

    final prefs = await SharedPreferences.getInstance();
    final drafts = await list(account);
    final now = DateTime.now();

    String? localMediaPath;
    if (imageBytes != null) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/draft_media_${now.microsecondsSinceEpoch}',
      );
      await file.writeAsBytes(imageBytes);
      localMediaPath = file.path;
    }

    final draft = LocalDraft(
      id: serverId ?? now.microsecondsSinceEpoch,
      serverId: serverId,
      accountId: account,
      localMediaPath: localMediaPath,
      imageName: imageName,
      caption: caption,
      channel: channel,
      mediaType: mediaType,
      backgroundColor: backgroundColor,
      font: font,
      scheduledTime: scheduledTime,
      repeat: repeat,
      createdAt: now,
      trimStart: trimStart,
      trimEnd: trimEnd,
      musicFilePath: musicFilePath,
      musicFileName: musicFileName,
      musicId: musicId,
      audioStartOffsetMs: audioStartOffsetMs,
      audioDurationMs: audioDurationMs,
      originalVolume: originalVolume,
      musicVolume: musicVolume,
      watermarkImagePath: watermarkImagePath,
      textOverlaysJson: textOverlaysJson,
      watermarkTransformJson: watermarkTransformJson,
    );
    drafts.insert(0, draft);
    if (drafts.length > _maxDrafts) {
      drafts.removeRange(_maxDrafts, drafts.length);
    }
    await prefs.setStringList(
      _keyFor(account),
      drafts.map((d) => jsonEncode(d.toJson())).toList(),
    );
    return draft;
  }

  /// Persists the current composer state as a draft in the account's drafts
  /// list. Triggered explicitly when the user saves a draft — no auto-save.
  Future<void> saveAutoDraft({
    int? serverId,
    int? accountId,
    Uint8List? imageBytes,
    String? imageName,
    required String caption,
    List<DraftImageBytes>? images,
    required PostChannel channel,
    PostMediaType mediaType = PostMediaType.image,
    String? backgroundColor,
    int? font,
    DateTime? scheduledTime,
    PostRepeat repeat = PostRepeat.once,
    int? editingPostId,
    required int sessionId,
    double? trimStart,
    double? trimEnd,
    String? musicFilePath,
    String? musicFileName,
    int? musicId,
    int? audioStartOffsetMs,
    int? audioDurationMs,
    double? originalVolume,
    double? musicVolume,
    String? watermarkImagePath,
    String? textOverlaysJson,
    String? watermarkTransformJson,
  }) async {
    final account = accountId;
    if (account == null) return;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dir = await getApplicationDocumentsDirectory();

    String? localMediaPath;
    String? primaryImageName;
    String primaryCaption = caption;
    final List<LocalDraftImage> storedImages = [];

    if (images != null && images.isNotEmpty) {
      // Multi-image draft: write every image to its own file and keep each
      // image's independent caption.
      for (var i = 0; i < images.length; i++) {
        final item = images[i];
        final file = File('${dir.path}/draft_media_${sessionId}_$i');
        await file.writeAsBytes(item.bytes);
        storedImages.add(
          LocalDraftImage(
            localMediaPath: file.path,
            imageName: item.name,
            caption: item.caption,
          ),
        );
      }
      localMediaPath = storedImages.first.localMediaPath;
      primaryImageName = storedImages.first.imageName;
      primaryCaption = storedImages.first.caption;
    } else if (imageBytes != null) {
      final file = File('${dir.path}/draft_media_$sessionId');
      await file.writeAsBytes(imageBytes);
      localMediaPath = file.path;
      primaryImageName = imageName;
    }

    final draft = LocalDraft(
      id: sessionId,
      serverId: serverId,
      accountId: account,
      localMediaPath: localMediaPath,
      imageName: primaryImageName,
      caption: primaryCaption,
      images: storedImages,
      channel: channel,
      mediaType: mediaType,
      backgroundColor: backgroundColor,
      font: font,
      scheduledTime: scheduledTime,
      repeat: repeat,
      createdAt: now,
      trimStart: trimStart,
      trimEnd: trimEnd,
      musicFilePath: musicFilePath,
      musicFileName: musicFileName,
      musicId: musicId,
      audioStartOffsetMs: audioStartOffsetMs,
      audioDurationMs: audioDurationMs,
      originalVolume: originalVolume,
      musicVolume: musicVolume,
      watermarkImagePath: watermarkImagePath,
      textOverlaysJson: textOverlaysJson,
      watermarkTransformJson: watermarkTransformJson,
    );

    // Populate the account's drafts list with this session's draft
    final drafts = await list(account);
    final idx = drafts.indexWhere((d) => d.id == draft.id);
    if (idx >= 0) {
      drafts[idx] = draft;
    } else {
      drafts.insert(0, draft);
      if (drafts.length > _maxDrafts) {
        drafts.removeRange(_maxDrafts, drafts.length);
      }
    }
    await prefs.setStringList(
      _keyFor(account),
      drafts.map((d) => jsonEncode(d.toJson())).toList(),
    );
  }

  Future<LocalDraft?> loadAutoDraft(int accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_autoKeyFor(accountId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final draft = LocalDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (draft.accountId != accountId) return null;
      return draft;
    } catch (_) {
      return null;
    }
  }

  /// Releases the account's auto-draft — called right after a post is
  /// created/sent. Deletes its media file and the account's auto-slot.
  Future<void> clearAutoDraft(int accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final draft = await loadAutoDraft(accountId);
    if (draft != null) {
      if (draft.localMediaPath != null) {
        try {
          await File(draft.localMediaPath!).delete();
        } catch (_) {}
      }
      await prefs.remove(_autoKeyFor(accountId));
    }
  }

  /// Deletes a draft for this account: removes the server record (best effort)
  /// and the account-scoped local content + media files.
  Future<void> delete(int id, {required int accountId}) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await list(accountId);
    final idx = drafts.indexWhere((d) => d.id == id);
    if (idx >= 0) {
      final draft = drafts[idx];
      if (draft.serverId != null) {
        await deleteServerDraft(draft.serverId!);
      }
      // Remove every image file belonging to this draft.
      for (final image in draft.images) {
        if (image.localMediaPath != null) {
          try {
            await File(image.localMediaPath!).delete();
          } catch (_) {}
        }
      }
      if (draft.localMediaPath != null) {
        try {
          await File(draft.localMediaPath!).delete();
        } catch (_) {}
      }
      drafts.removeAt(idx);
      await prefs.setStringList(
        _keyFor(accountId),
        drafts.map((d) => jsonEncode(d.toJson())).toList(),
      );
    }
  }

  Future<void> clear(int accountId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(accountId));
    await prefs.remove(_autoKeyFor(accountId));
  }

  /// Full session wipe: removes every account-scoped draft/auto key and all
  /// on-disk media/thumbnail files. Called by the session on logout so a new
  /// user starts completely fresh.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().toList()) {
      if (key.startsWith(_keyPrefix) || key.startsWith(_autoKeyPrefix)) {
        await prefs.remove(key);
      }
    }

    // Delete every draft media file we wrote to the app Documents directory.
    try {
      final dir = await getApplicationDocumentsDirectory();
      await for (final entry in _iterDir(dir)) {
        final name = entry.path.split(Platform.pathSeparator).last;
        if (name.startsWith('draft_media_') ||
            name.startsWith('draft_thumb_')) {
          try {
            await File(entry.path).delete();
          } catch (_) {}
        }
      }
    } catch (_) {
      // Directory may not be reachable — best-effort only.
    }
  }

  Stream<File> _iterDir(Directory dir) async* {
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is File) {
        yield entity;
      } else if (entity is Directory) {
        yield* _iterDir(entity);
      }
    }
  }
}
