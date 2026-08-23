import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../core/constants/post_channel.dart';
import '../core/constants/post_media_type.dart';
import '../core/constants/post_repeat.dart';
import '../core/session/session.dart';
import '../models/post_schedule_model.dart';
import '../services/draft_service.dart';
import '../services/schedule_service.dart';

class MultiImageItem {
  final Uint8List bytes;
  final String name;
  String caption;

  MultiImageItem({required this.bytes, required this.name, this.caption = ''});
}

/// Draft state for the create-post flow (image + caption + channel + time).
class CreatePostProvider extends ChangeNotifier {
  CreatePostProvider({ScheduleService? service, this.session})
    : _service = service ?? ScheduleService(),
      _draftService = DraftService() {
    _sessionId = DateTime.now().microsecondsSinceEpoch;
  }

  final ScheduleService _service;
  final Session? session;
  final DraftService _draftService;

  PostMediaType _mediaType = PostMediaType.image;
  Uint8List? _imageBytes;
  String? _imageName;
  Uint8List? _thumbnailBytes;
  String _caption = '';
  PostChannel _channel = PostChannel.waStatus;
  String? _backgroundColor;
  int? _font;
  DateTime? _scheduledTime;
  PostRepeat _repeat = PostRepeat.once;
  Map<String, dynamic>? _recurrenceRule;
  bool _isSubmitting = false;
  String? _submitError;
  int? _editingPostId;
  late int _sessionId;
  int? _draftServerId;
  Future<int?>? _ensureServerIdFuture;

  // Multi-Image State
  final List<MultiImageItem> _multiImages = [];
  int _currentMultiImageIndex = 0;

  // Video Editing State
  double? _trimStart;
  double? _trimEnd;
  String? _musicFilePath;
  String? _musicFileName;
  int? _musicId;
  int? _audioStartOffsetMs;
  int? _audioDurationMs;
  double? _originalVolume;
  double? _musicVolume;
  String? _watermarkImagePath;
  String? _textOverlaysJson;
  String? _watermarkTransformJson;

  PostMediaType get mediaType => _mediaType;
  PostChannel get channel => _channel;
  String? get backgroundColor => _backgroundColor;
  int? get font => _font;
  DateTime? get scheduledTime => _scheduledTime;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  bool get isEditing => _editingPostId != null;
  PostRepeat get repeat => _repeat;
  Map<String, dynamic>? get recurrenceRule => _recurrenceRule;

  // Multi-Image Getters
  List<MultiImageItem> get multiImages => _multiImages;
  int get currentMultiImageIndex => _currentMultiImageIndex;

  Uint8List? get imageBytes {
    if (_mediaType == PostMediaType.image && _multiImages.isNotEmpty) {
      if (_currentMultiImageIndex < _multiImages.length) {
        return _multiImages[_currentMultiImageIndex].bytes;
      }
      return null;
    }
    return _imageBytes;
  }

  String? get imageName {
    if (_mediaType == PostMediaType.image && _multiImages.isNotEmpty) {
      if (_currentMultiImageIndex < _multiImages.length) {
        return _multiImages[_currentMultiImageIndex].name;
      }
      return null;
    }
    return _imageName;
  }

  Uint8List? get thumbnailBytes => _thumbnailBytes;

  String get caption {
    if (_mediaType == PostMediaType.image && _multiImages.isNotEmpty) {
      if (_currentMultiImageIndex < _multiImages.length) {
        return _multiImages[_currentMultiImageIndex].caption;
      }
      // The "+ add new image" slot never shows another image's caption.
      return '';
    }
    return _caption;
  }

  bool get hasImage {
    if (_mediaType == PostMediaType.image) return _multiImages.isNotEmpty;
    return _imageBytes != null;
  }

  bool get hasCaption {
    return caption.trim().isNotEmpty;
  }

  // Video Editing Getters
  double? get trimStart => _trimStart;
  double? get trimEnd => _trimEnd;
  String? get musicFilePath => _musicFilePath;
  String? get musicFileName => _musicFileName;
  int? get musicId => _musicId;
  int? get audioStartOffsetMs => _audioStartOffsetMs;
  int? get audioDurationMs => _audioDurationMs;
  double? get originalVolume => _originalVolume;
  double? get musicVolume => _musicVolume;
  String? get watermarkImagePath => _watermarkImagePath;
  String? get textOverlaysJson => _textOverlaysJson;
  String? get watermarkTransformJson => _watermarkTransformJson;

  bool get isValid {
    switch (_mediaType) {
      case PostMediaType.text:
        return hasCaption;
      case PostMediaType.image:
        return hasImage;
      case PostMediaType.video:
        return hasImage;
    }
  }

  void setMediaType(PostMediaType type) {
    if (_mediaType != type) {
      _mediaType = type;

      notifyListeners();
    }
  }

  void addMultiImage(Uint8List bytes, String name) {
    // A freshly added image always starts with its own empty caption — never
    // inherit the shared fallback from another image.
    _multiImages.add(MultiImageItem(bytes: bytes, name: name, caption: ''));
    _currentMultiImageIndex = _multiImages.length - 1;

    notifyListeners();
  }

  void selectMultiImage(int index) {
    if (index >= 0 && index <= _multiImages.length) {
      _currentMultiImageIndex = index;
      notifyListeners();
    }
  }

  void removeMultiImage(int index) {
    _multiImages.removeAt(index);
    if (_multiImages.isEmpty) {
      _currentMultiImageIndex = 0;
    } else if (_currentMultiImageIndex >= _multiImages.length) {
      _currentMultiImageIndex = _multiImages.length - 1;
    }

    notifyListeners();
  }

  void setImage(Uint8List bytes, String name, {Uint8List? thumbnail}) {
    if (_mediaType == PostMediaType.image) {
      if (_multiImages.isEmpty) {
        _multiImages.add(
          MultiImageItem(bytes: bytes, name: name, caption: _caption),
        );
        _currentMultiImageIndex = 0;
      } else {
        _multiImages[_currentMultiImageIndex] = MultiImageItem(
          bytes: bytes,
          name: name,
          caption: _multiImages[_currentMultiImageIndex].caption,
        );
      }
    } else {
      _imageBytes = bytes;
      _imageName = name;
      _thumbnailBytes = thumbnail;
    }

    notifyListeners();
  }

  void clearImage() {
    if (_mediaType == PostMediaType.image && _multiImages.isNotEmpty) {
      if (_currentMultiImageIndex < _multiImages.length) {
        removeMultiImage(_currentMultiImageIndex);
      }
    } else {
      _imageBytes = null;
      _imageName = null;
      _thumbnailBytes = null;
    }

    notifyListeners();
  }

  void setCaption(String value) {
    if (_mediaType == PostMediaType.image && _multiImages.isNotEmpty) {
      if (_currentMultiImageIndex < _multiImages.length) {
        _multiImages[_currentMultiImageIndex].caption = value;
      } else {
        _caption = value;
      }
    } else {
      _caption = value;
    }

    notifyListeners();
  }

  void setChannel(PostChannel value) {
    _channel = value;

    notifyListeners();
  }

  void setBackgroundColor(String? value) {
    if (_backgroundColor != value) {
      _backgroundColor = value;

      notifyListeners();
    }
  }

  void setFont(int? value) {
    if (_font != value) {
      _font = value;

      notifyListeners();
    }
  }

  void setScheduledTime(DateTime value) {
    _scheduledTime = value;

    notifyListeners();
  }

  void setRepeat(PostRepeat value) {
    _repeat = value;

    notifyListeners();
  }

  void setRecurrenceRule(Map<String, dynamic>? value) {
    _recurrenceRule = value;
    notifyListeners();
  }

  // --- Video Edit Actions ---
  void setTrim(double? start, double? end) {
    _trimStart = start;
    _trimEnd = end;

    notifyListeners();
  }

  void setAudioOffset(int? offsetMs, int? durationMs) {
    _audioStartOffsetMs = offsetMs;
    _audioDurationMs = durationMs;

    notifyListeners();
  }

  void setMusic(String? filePath, String? fileName, int? id) {
    _musicFilePath = filePath;
    _musicFileName = fileName;
    _musicId = id;
    if (filePath == null) {
      _musicVolume = null;
      _originalVolume = null;
      _audioStartOffsetMs = null;
      _audioDurationMs = null;
    }

    notifyListeners();
  }

  void setVolumes(double? original, double? music) {
    _originalVolume = original;
    _musicVolume = music;

    notifyListeners();
  }

  void setWatermarkPath(String? path) {
    _watermarkImagePath = path;

    notifyListeners();
  }

  void setWatermarkTransform(String? jsonString) {
    _watermarkTransformJson = jsonString;

    notifyListeners();
  }

  void setTextOverlays(String? jsonString) {
    _textOverlaysJson = jsonString;

    notifyListeners();
  }

  /// Batched video-edit sync from the composer. Sets every edit field at once
  /// so the [VideoStatusScreen] can push its whole editor state into the draft.
  void setVideoEdits({
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
    String? watermarkTransformJson,
    String? textOverlaysJson,
  }) {
    _trimStart = trimStart;
    _trimEnd = trimEnd;
    _musicFilePath = musicFilePath;
    _musicFileName = musicFileName;
    _musicId = musicId;
    _audioStartOffsetMs = audioStartOffsetMs;
    _audioDurationMs = audioDurationMs;
    _originalVolume = originalVolume;
    _musicVolume = musicVolume;
    _watermarkImagePath = watermarkImagePath;
    _watermarkTransformJson = watermarkTransformJson;
    _textOverlaysJson = textOverlaysJson;

    notifyListeners();
  }

  void clearVideoEdits() {
    _trimStart = null;
    _trimEnd = null;
    _musicFilePath = null;
    _musicFileName = null;
    _musicId = null;
    _audioStartOffsetMs = null;
    _audioDurationMs = null;
    _originalVolume = null;
    _musicVolume = null;
    _watermarkImagePath = null;
    _textOverlaysJson = null;
    _watermarkTransformJson = null;

    notifyListeners();
  }

  /// The account (business id) currently logged in, or null when signed out.
  int? get accountId => session?.businessId;

  /// Ensures this compose session has a server-created draft id owned by the
  /// current account. Content stays local; only the id is created online.
  /// Editing an existing post reuses the post's own session — no draft record.
  Future<int?> _ensureDraftServerId() async {
    if (_editingPostId != null) return null;
    if (_draftServerId != null) return _draftServerId;
    // Deduplicate concurrent saves so only one server draft is created per
    // compose session.
    if (_ensureServerIdFuture != null) return _ensureServerIdFuture;
    final account = accountId;
    if (account == null) return null;
    _ensureServerIdFuture = () async {
      try {
        _draftServerId = await _draftService.createServerDraft(
          accountId: account,
          mediaType: _mediaType,
          channel: _channel,
        );
      } catch (_) {
        // Offline or server error — content is still drafted locally; it just
        // won't be shown until it has a matching server id for this account.
      }
      return _draftServerId;
    }();
    final result = await _ensureServerIdFuture;
    _ensureServerIdFuture = null;
    return result;
  }

  /// Saves the current composer content as a draft (server id + local content)
  /// for the logged-in account. Triggered explicitly by the user from the
  /// composer's back-guard dialog — no auto-draft.
  Future<void> saveAsDraft() async {
    final account = accountId;
    final List<DraftImageBytes> imageList = [];
    Uint8List? saveBytes;
    String? saveName;
    String saveCaption = _caption;

    if (_mediaType == PostMediaType.image && _multiImages.isNotEmpty) {
      // Persist every picked image together with its own caption.
      for (final item in _multiImages) {
        imageList.add(
          DraftImageBytes(
            bytes: item.bytes,
            name: item.name,
            caption: item.caption,
          ),
        );
      }
      saveBytes = _multiImages.first.bytes;
      saveName = _multiImages.first.name;
      saveCaption = _multiImages.first.caption;
    } else {
      saveBytes = _imageBytes;
      saveName = _imageName;
    }

    // Create the online draft id (per account) for this session — only once
    // there is real content to draft, so empty composer sessions don't leave
    // orphan server records.
    final serverId = hasImage || hasCaption
        ? await _ensureDraftServerId()
        : null;

    try {
      await _draftService.saveAutoDraft(
        serverId: serverId,
        accountId: account,
        imageBytes: saveBytes,
        imageName: saveName,
        caption: saveCaption,
        images: imageList.isEmpty ? null : imageList,
        channel: _channel,
        mediaType: _mediaType,
        backgroundColor: _backgroundColor,
        font: _font,
        scheduledTime: _scheduledTime,
        repeat: _repeat,
        editingPostId: _editingPostId,
        sessionId: _editingPostId ?? _sessionId,
        trimStart: _trimStart,
        trimEnd: _trimEnd,
        musicFilePath: _musicFilePath,
        musicFileName: _musicFileName,
        musicId: _musicId,
        audioStartOffsetMs: _audioStartOffsetMs,
        audioDurationMs: _audioDurationMs,
        originalVolume: _originalVolume,
        musicVolume: _musicVolume,
        watermarkImagePath: _watermarkImagePath,
        textOverlaysJson: _textOverlaysJson,
        watermarkTransformJson: _watermarkTransformJson,
      );
    } catch (_) {}
  }

  /// Loads a specific draft from the Drafts screen.
  Future<void> loadLocalDraft(LocalDraft draft) async {
    _sessionId = draft.id;
    _draftServerId = draft.serverId;
    _editingPostId = null;

    _multiImages.clear();
    _currentMultiImageIndex = 0;

    // Restore every saved image together with its own caption.
    if (draft.images.isNotEmpty) {
      for (final image in draft.images) {
        if (image.localMediaPath == null) continue;
        try {
          final bytes = await File(image.localMediaPath!).readAsBytes();
          if (draft.mediaType == PostMediaType.image) {
            _multiImages.add(
              MultiImageItem(
                bytes: bytes,
                name: image.imageName ?? 'image.jpg',
                caption: image.caption,
              ),
            );
          }
        } catch (_) {}
      }
    } else if (draft.localMediaPath != null) {
      try {
        _imageBytes = await File(draft.localMediaPath!).readAsBytes();
        if (draft.mediaType == PostMediaType.image) {
          _multiImages.add(
            MultiImageItem(
              bytes: _imageBytes!,
              name: draft.imageName ?? 'image.jpg',
              caption: draft.caption,
            ),
          );
        }
      } catch (_) {}
    } else {
      _imageBytes = null;
    }

    _imageName = draft.images.isNotEmpty
        ? draft.images.first.imageName
        : draft.imageName;
    _caption = draft.images.isNotEmpty
        ? draft.images.first.caption
        : draft.caption;
    _channel = draft.channel;
    _mediaType = draft.mediaType;
    _backgroundColor = draft.backgroundColor;
    _font = draft.font;
    _scheduledTime = draft.scheduledTime;
    _repeat = draft.repeat;

    _trimStart = draft.trimStart;
    _trimEnd = draft.trimEnd;
    _musicFilePath = draft.musicFilePath;
    _musicFileName = draft.musicFileName;
    _musicId = draft.musicId;
    _audioStartOffsetMs = draft.audioStartOffsetMs;
    _audioDurationMs = draft.audioDurationMs;
    _originalVolume = draft.originalVolume;
    _musicVolume = draft.musicVolume;
    _watermarkImagePath = draft.watermarkImagePath;
    _textOverlaysJson = draft.textOverlaysJson;
    _watermarkTransformJson = draft.watermarkTransformJson;

    _submitError = null;
    notifyListeners();
  }

  /// Loads an existing pending post into the draft for editing.
  Future<void> loadForEdit(PostScheduleModel post) async {
    _editingPostId = post.id;
    _mediaType = post.mediaType;
    _caption = post.caption;
    _channel = post.channel;
    _backgroundColor = post.backgroundColor;
    _font = post.font;
    _scheduledTime = post.scheduledTime;
    _repeat = post.repeat;
    _imageName = null;
    _submitError = null;
    _imageBytes = null;
    _multiImages.clear();
    _currentMultiImageIndex = 0;

    if (post.localMediaPath != null) {
      try {
        _imageBytes = await File(post.localMediaPath!).readAsBytes();
        if (_mediaType == PostMediaType.image) {
          _multiImages.add(
            MultiImageItem(
              bytes: _imageBytes!,
              name: 'image.jpg',
              caption: _caption,
            ),
          );
        }
      } catch (_) {}
    } else if (post.localImage != null) {
      _imageBytes = post.localImage;
      if (_mediaType == PostMediaType.image) {
        _multiImages.add(
          MultiImageItem(
            bytes: _imageBytes!,
            name: 'image.jpg',
            caption: _caption,
          ),
        );
      }
    }
    notifyListeners();
  }

  /// Submits the draft to the backend as a scheduled post.
  Future<List<PostScheduleModel>> submit({
    int? businessId,
    DateTime? scheduledTime,
    Map<String, dynamic>? recurrenceRule,
  }) async {
    final time =
        scheduledTime ??
        _scheduledTime ??
        DateTime.now().add(const Duration(hours: 1));
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();
    try {
      final List<PostScheduleModel> posts = [];
      final rule = recurrenceRule ?? _recurrenceRule;
      if (_editingPostId != null) {
        final post = await _service.updatePost(
          _editingPostId!,
          caption: caption,
          type: _mediaType,
          backgroundColor: _backgroundColor,
          font: _font,
          channel: _channel,
          scheduledTime: time,
          repeat: _repeat,
          recurrenceRule: rule,
          imageBytes: imageBytes,
          imageName: imageName,
        );
        posts.add(post);
      } else {
        if (_mediaType == PostMediaType.image && _multiImages.length > 1) {
          for (final item in _multiImages) {
            final post = await _service.createPost(
              caption: item.caption,
              type: _mediaType,
              backgroundColor: _backgroundColor,
              font: _font,
              imageBytes: item.bytes,
              imageName: item.name,
              channel: _channel,
              scheduledTime: time,
              repeat: _repeat,
              recurrenceRule: rule,
              businessId: businessId,
            );
            posts.add(post);
          }
        } else {
          final post = await _service.createPost(
            caption: caption,
            type: _mediaType,
            backgroundColor: _backgroundColor,
            font: _font,
            imageBytes: imageBytes,
            imageName: imageName ?? 'poster.webp',
            channel: _channel,
            scheduledTime: time,
            repeat: _repeat,
            recurrenceRule: rule,
            businessId: businessId,
          );
          posts.add(post);
        }
      }
      return posts;
    } catch (e) {
      _submitError = '$e';
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Discards the persisted draft slot (media file + preferences). Called once
  /// the rendered media has been handed off to the scheduler. Runs in the
  /// background.
  Future<void> releaseAutoDraft() async {
    final account = accountId;
    if (account == null) return;
    await _draftService.clearAutoDraft(account);
    _draftServerId = null;
  }

  void reset() {
    _sessionId = DateTime.now().microsecondsSinceEpoch;
    _draftServerId = null;
    _editingPostId = null;
    _imageBytes = null;
    _imageName = null;
    _caption = '';
    _multiImages.clear();
    _currentMultiImageIndex = 0;
    _channel = PostChannel.waStatus;
    _backgroundColor = null;
    _font = null;
    _scheduledTime = null;
    _repeat = PostRepeat.once;
    _recurrenceRule = null;
    _mediaType = PostMediaType.image;

    clearVideoEdits();

    _submitError = null;
    notifyListeners();
  }
}
