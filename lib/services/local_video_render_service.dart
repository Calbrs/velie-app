import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_audio/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_audio/return_code.dart';
import 'package:ffmpeg_kit_flutter_audio/statistics.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

import '../models/video_composition_model.dart';

/// Renders a status video entirely on the device (no upload) using FFmpeg:
///
///   - the raw video is scaled/padded to [resolution]
///   - a watermark image (optional) is scaled and overlaid
///   - every [VideoTextOverlay] is rasterized into a transparent PNG (dart:ui)
///     and overlaid at its absolute position
///   - a trimmed music track (optional) is looped to cover the whole video
///   - H.264 + AAC output, progress reported through [onProgress] (0..1)
class LocalVideoRenderService {
  /// Runs a single render job and returns the finished `.mp4` bytes.
  Future<Uint8List> render({
    required Uint8List videoBytes,
    required String videoExtension,
    String? musicPath,
    Duration? audioStartOffset,
    String? watermarkPath,
    List<VideoTextOverlay> textOverlays = const [],
    double? trimStart,
    double? trimEnd,
    String resolution = '1080x1920',
    void Function(double progress)? onProgress,
  }) async {
    final tmp = await getTemporaryDirectory();
    final jobId = DateTime.now().millisecondsSinceEpoch;
    final base = tmp.path;

    final sourcePath = '$base${Platform.pathSeparator}source_$jobId.$videoExtension';
    final outputPath = '$base${Platform.pathSeparator}rendered_$jobId.mp4';
    final sourceFile = File(sourcePath);
    await sourceFile.writeAsBytes(videoBytes, flush: true);

    final textPaths = <String>[];
    try {
      for (var i = 0; i < textOverlays.length; i++) {
        final png = await _rasterizeTextOverlay(
          textOverlays[i],
          width: _resolutionWidth(resolution),
        );
        final path = '$base${Platform.pathSeparator}text_${jobId}_$i.png';
        await File(path).writeAsBytes(png, flush: true);
        textPaths.add(path);
      }

      // Probe the source length once so progress and the music cap are correct.
      final durationMs = await _probeDurationMs(sourcePath);

      final args = _buildCommand(
        sourcePath: sourcePath,
        outputPath: outputPath,
        musicPath: musicPath,
        audioStartOffset: audioStartOffset,
        watermarkPath: watermarkPath,
        textOverlays: textOverlays,
        textPaths: textPaths,
        trimStart: trimStart,
        trimEnd: trimEnd,
        resolution: resolution,
        durationMs: durationMs,
      );

      final completer = Completer<Uint8List>();
      await FFmpegKit.executeWithArgumentsAsync(
        args,
        (session) async {
          final code = await session.getReturnCode();
          if (ReturnCode.isSuccess(code) &&
              File(outputPath).existsSync()) {
            completer.complete(await File(outputPath).readAsBytes());
          } else {
            completer.completeError(
              Exception('Render imeshindwa (returnCode=${code?.getValue()})'),
            );
          }
        },
        null,
        durationMs != null
            ? (Statistics stat) {
                final timeMs = stat.getTime();
                if (timeMs > 0 && durationMs > 0) {
                  onProgress?.call((timeMs / durationMs).clamp(0.0, 1.0));
                }
              }
            : null,
      );

      return await completer.future;
    } finally {
      for (final path in [sourcePath, ...textPaths]) {
        final f = File(path);
        if (f.existsSync()) {
          try {
            f.deleteSync();
          } catch (_) {}
        }
      }
      final out = File(outputPath);
      if (out.existsSync()) {
        try {
          out.deleteSync();
        } catch (_) {}
      }
    }
  }

  // ---------------------------------------------------------------------
  // COMMAND BUILDING
  // ---------------------------------------------------------------------

  List<String> _buildCommand({
    required String sourcePath,
    required String outputPath,
    required String? musicPath,
    required Duration? audioStartOffset,
    required String? watermarkPath,
    required List<VideoTextOverlay> textOverlays,
    required List<String> textPaths,
    required double? trimStart,
    required double? trimEnd,
    required String resolution,
    required double? durationMs,
  }) {
    final width = _resolutionWidth(resolution);
    final height = _resolutionHeight(resolution);

    final args = <String>['-y'];

    // If we have a valid duration and trim fractions, apply fast-seeking
    double? actualDurationMs = durationMs;
    if (durationMs != null && trimStart != null && trimEnd != null) {
      final startSec = (trimStart * durationMs) / 1000.0;
      final endSec = (trimEnd * durationMs) / 1000.0;
      actualDurationMs = (endSec - startSec) * 1000.0;
      args.addAll(['-ss', startSec.toStringAsFixed(3)]);
      args.addAll(['-to', endSec.toStringAsFixed(3)]);
    }

    // Input 0: the raw source video.
    args.addAll(['-i', sourcePath]);
    var nextInput = 1;

    // [0:v] -> scaled & padded to the target resolution.
    final filters = <String>[
      '[0:v]scale=$width:$height:force_original_aspect_ratio=decrease,'
          'pad=$width:$height:(ow-iw)/2:(oh-ih)/2,setsar=1[base]',
    ];
    var current = 'base';

    // Optional watermark (input 1): scale to half size, burn in the corner.
    if (watermarkPath != null) {
      final wi = nextInput;
      args.addAll(['-i', watermarkPath]);
      filters.add(
        '[$wi:v]scale=max(2,trunc(iw*0.5/2)*2):max(2,trunc(ih*0.5/2)*2),'
        'setsar=1[wm]',
      );
      filters.add('[base][wm]overlay=x=50:y=100[owm]');
      current = 'owm';
      nextInput++;
    }

    // Text overlays: each is its own transparent PNG positioned at its point.
    for (var i = 0; i < textOverlays.length; i++) {
      final ti = nextInput++;
      args.addAll(['-i', textPaths[i]]);
      final x = _clamp(textOverlays[i].xPosition.round(), 0, width);
      final y = _clamp(textOverlays[i].yPosition.round(), 0, height);
      filters.add('[$current][$ti:v]overlay=$x:$y[t$i]');
      current = 't$i';
    }

    // Music last so its input index is stable and never shifts overlays.
    var musicInputIndex = -1;
    if (musicPath != null) {
      musicInputIndex = nextInput;
      args.addAll(['-stream_loop', '-1']);
      if (audioStartOffset != null && audioStartOffset.inMilliseconds > 0) {
        args.addAll(['-ss', (audioStartOffset.inMilliseconds / 1000).toStringAsFixed(3)]);
      }
      args.addAll(['-i', musicPath]);
    }

    args.addAll(['-filter_complex', filters.join(';')]);
    args.addAll(['-map', '[$current]']);

    if (musicInputIndex > 0) {
      args.addAll(['-map', '$musicInputIndex:a']);
      // The track was already trimmed; looped via -stream_loop. Cap to video.
      if (actualDurationMs != null) {
        args.addAll(['-t', (actualDurationMs / 1000).toStringAsFixed(3)]);
      } else {
        // Probe failed: without a cap the -stream_loop -1 input makes the
        // encode run forever. -shortest ends when the finite video stream ends.
        args.addAll(['-shortest']);
      }
    } else {
      // No music chosen: keep the source audio when a track exists.
      args.addAll(['-map', '0:a?']);
    }

    args.addAll([
      '-c:v', 'libx264',
      '-preset', 'veryfast',
      '-crf', '23',
      '-pix_fmt', 'yuv420p',
      '-movflags', '+faststart',
      '-c:a', 'aac',
      '-b:a', '192k',
    ]);

    args.addAll(['-y', outputPath]);
    return args;
  }

  // ---------------------------------------------------------------------
  // TEXT RASTERIZATION
  // ---------------------------------------------------------------------

  /// Draws a [VideoTextOverlay] onto a transparent PNG so FFmpeg only has to
  /// `overlay` it — the full-GPL build has no `drawtext` filter.
  Future<Uint8List> _rasterizeTextOverlay(
    VideoTextOverlay overlay, {
    required int width,
  }) async {
    final color = _parseHexColor(overlay.color);

    final painter = TextPainter(
      text: TextSpan(
        text: overlay.text,
        style: TextStyle(
          fontSize: overlay.fontSize,
          color: color,
          fontWeight: FontWeight.bold,
          height: 1.2,
          shadows: const [
            Shadow(
              color: Color(0x8C000000),
              blurRadius: 4,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start,
    );

    // Allow wrapping so long text never overflows the canvas.
    final maxWidth = (width - overlay.xPosition).clamp(80.0, double.infinity);
    painter.maxLines = 6;
    painter.layout(maxWidth: maxWidth);

    final rawW = painter.width.ceil() + 4;
    final rawH = painter.height.ceil() + 4;
    final evenW = rawW.isEven ? rawW : rawW + 1;
    final evenH = rawH.isEven ? rawH : rawH + 1;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    painter.paint(canvas, const Offset(2, 2));

    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(evenW, evenH);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        if (data == null) {
          throw Exception('Haikuweza kutoa picha ya maandishi');
        }
        return data.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }

  // ---------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------

  Future<double?> _probeDurationMs(String path) async {
    try {
      final info = await FFprobeKit.getMediaInformation(path);
      final duration = info.getMediaInformation()?.getDuration();
      if (duration == null) return null;
      final parsed = double.tryParse(duration.toString());
      return parsed != null && parsed > 0 ? parsed * 1000 : null;
    } catch (_) {
      return null;
    }
  }

  static int _resolutionWidth(String resolution) =>
      int.parse(resolution.split('x').first);

  static int _resolutionHeight(String resolution) =>
      int.parse(resolution.split('x').last);

  static int _clamp(int value, int min, int max) =>
      value < min ? min : (value > max ? max : value);

  static Color _parseHexColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16) ?? 0xFFFFFF;
    return Color(0xFF000000 | value);
  }
}