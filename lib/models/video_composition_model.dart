import 'package:flutter/foundation.dart';

/// Declarative description of the edits applied to a raw status video.
///
/// Mirrors the backend's `POST /api/v1/video/render` body — the backend
/// translates this into the JSON2Video payload, so the app never processes
/// video locally.
@immutable
class VideoComposition {
  const VideoComposition({
    required this.sourceVideoUrl,
    this.resolution = '1080x1920',
    this.trim,
    this.watermark,
    this.textOverlays = const [],
    this.backgroundMusic,
  });

  /// Public URL of the uploaded raw video (`/uploads/...` or absolute).
  final String sourceVideoUrl;

  /// Output frame, e.g. `1080x1920` (vertical) or `1920x1080` (horizontal).
  final String resolution;

  /// Trim window within the source video, or null to keep it whole.
  final VideoTrim? trim;

  /// Optional business logo burned into the corner of the video.
  final VideoWatermark? watermark;

  /// Text snippets rendered over the video (price, phone, location, …).
  final List<VideoTextOverlay> textOverlays;

  /// Optional background music mixed into the exported video.
  final VideoBackgroundMusic? backgroundMusic;

  bool get hasEdits =>
      trim != null ||
      watermark != null ||
      textOverlays.isNotEmpty ||
      backgroundMusic != null;

  Map<String, dynamic> toJson() => {
        'source_video_url': sourceVideoUrl,
        'resolution': resolution,
        if (trim != null) 'trim': trim!.toJson(),
        if (watermark != null) 'watermark': watermark!.toJson(),
        'text_overlays': textOverlays.map((e) => e.toJson()).toList(),
        if (backgroundMusic != null) 'background_music': backgroundMusic!.toJson(),
      };

  VideoComposition copyWith({
    String? sourceVideoUrl,
    String? resolution,
    VideoTrim? trim,
    bool clearTrim = false,
    VideoWatermark? watermark,
    bool clearWatermark = false,
    List<VideoTextOverlay>? textOverlays,
    VideoBackgroundMusic? backgroundMusic,
    bool clearMusic = false,
  }) {
    return VideoComposition(
      sourceVideoUrl: sourceVideoUrl ?? this.sourceVideoUrl,
      resolution: resolution ?? this.resolution,
      trim: clearTrim ? null : (trim ?? this.trim),
      watermark: clearWatermark ? null : (watermark ?? this.watermark),
      textOverlays: textOverlays ?? this.textOverlays,
      backgroundMusic: clearMusic ? null : (backgroundMusic ?? this.backgroundMusic),
    );
  }
}

/// Trim window: `start_time` → `end_time` in seconds.
@immutable
class VideoTrim {
  const VideoTrim({required this.startTime, required this.endTime});

  final double startTime;
  final double endTime;

  Map<String, dynamic> toJson() => {
        'start_time': startTime,
        'end_time': endTime,
      };
}

/// Watermark image burned into the output at an absolute pixel position.
@immutable
class VideoWatermark {
  const VideoWatermark({
    required this.imageUrl,
    this.xPosition = 50,
    this.yPosition = 100,
    this.scale = 0.5,
  });

  final String imageUrl;
  final double xPosition;
  final double yPosition;
  final double scale;

  Map<String, dynamic> toJson() => {
        'image_url': imageUrl,
        'x_position': xPosition,
        'y_position': yPosition,
        'scale': scale,
      };
}

/// A text snippet overlaid on the video at a pixel position.
@immutable
class VideoTextOverlay {
  const VideoTextOverlay({
    required this.text,
    this.fontSize = 48,
    this.color = '#FFFFFF',
    this.xPosition = 200,
    this.yPosition = 800,
  });

  final String text;
  final double fontSize;
  final String color;
  final double xPosition;
  final double yPosition;

  Map<String, dynamic> toJson() => {
        'text': text,
        'font_size': fontSize,
        'color': color,
        'x_position': xPosition,
        'y_position': yPosition,
      };

  factory VideoTextOverlay.fromJson(Map<String, dynamic> json) {
    return VideoTextOverlay(
      text: json['text'] as String,
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 48.0,
      color: json['color'] as String? ?? '#FFFFFF',
      xPosition: (json['x_position'] as num?)?.toDouble() ?? 200.0,
      yPosition: (json['y_position'] as num?)?.toDouble() ?? 800.0,
    );
  }
}

/// Background music mixed into the exported video.
@immutable
class VideoBackgroundMusic {
  const VideoBackgroundMusic({
    required this.audioUrl,
    this.startOffset = 0.0,
    this.volume = 0.8,
    this.muteOriginalAudio = true,
  });

  final String audioUrl;
  final double startOffset;
  final double volume;
  final bool muteOriginalAudio;

  Map<String, dynamic> toJson() => {
        'audio_url': audioUrl,
        'start_offset': startOffset,
        'volume': volume,
        'mute_original_audio': muteOriginalAudio,
      };
}
