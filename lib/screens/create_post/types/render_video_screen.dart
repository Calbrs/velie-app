import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/video_composition_model.dart';
import '../../../providers/create_post_provider.dart';
import '../../../services/local_video_render_service.dart';

/// Extra data pushed to `/post/render` alongside the draft video (which lives
/// in [CreatePostProvider]).
class VideoRenderOptions {
  const VideoRenderOptions({
    this.musicPath,
    this.audioStartOffset,
    this.watermarkPath,
    this.textOverlays = const [],
    this.trimStart,
    this.trimEnd,
  });

  final String? musicPath;
  final Duration? audioStartOffset;
  final String? watermarkPath;
  final List<VideoTextOverlay> textOverlays;
  final double? trimStart;
  final double? trimEnd;
}

/// Composes the status video locally on-device with FFmpeg (no upload), then
/// drops the finished video into the draft so the post scheduler can pick it up:
///
///   1. Probe the raw draft video
///   2. Rasterize text overlays, run one FFmpeg filtergraph that scales the
///      video, burns the watermark/text PNGs and mixes the trimmed music
///   4. Store the rendered `.mp4` as the draft media, continue to scheduling
class RenderVideoScreen extends StatefulWidget {
  const RenderVideoScreen({super.key, this.options});

  final VideoRenderOptions? options;

  @override
  State<RenderVideoScreen> createState() => _RenderVideoScreenState();
}

class _RenderVideoScreenState extends State<RenderVideoScreen> {
  final LocalVideoRenderService _service = LocalVideoRenderService();
  late final String _preparingLabel;
  String _statusLabel = '';
  String? _error;
  double? _progress;

  @override
  void initState() {
    super.initState();
    _preparingLabel = AppLocalizations.of(context).preparingVideoOnDevice;
    _statusLabel = _preparingLabel;
    _run();
  }

  Future<void> _run() async {
    final draft = context.read<CreatePostProvider>();
    if (draft.imageBytes == null) {
      setState(() => _error = AppLocalizations.of(context).chooseVideoFirst);
      return;
    }
    setState(() {
      _statusLabel = AppLocalizations.of(context).preparingVideoOnDevice;
      _progress = null;
      _error = null;
    });
    try {
      final videoExtension = _videoExtensionOf(draft.imageName);
      final outputBytes = await _service.render(
        videoBytes: draft.imageBytes!,
        videoExtension: videoExtension,
        musicPath: widget.options?.musicPath,
        audioStartOffset: widget.options?.audioStartOffset,
        watermarkPath: widget.options?.watermarkPath,
        textOverlays: widget.options?.textOverlays ?? const [],
        trimStart: widget.options?.trimStart,
        trimEnd: widget.options?.trimEnd,
        resolution: '1080x1920',
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _progress = progress;
            _statusLabel = AppLocalizations.of(context).videoFinalizing((progress * 100).round());
          });
        },
      );

      if (!mounted) return;
      context.read<CreatePostProvider>().setImage(outputBytes, 'rendered_video.mp4');
      context.go('/post/schedule');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  static String _videoExtensionOf(String? name) {
    if (name == null) return 'mp4';
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return 'mp4';
    final ext = name.substring(dot + 1).toLowerCase();
    return ext.isEmpty ? 'mp4' : ext;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_error == null) ...[
                const SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                if (_progress != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceMuted,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  _statusLabel,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).dontLeavePageRendering,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ] else ...[
                Icon(Icons.error_outline, color: AppColors.statusFailed, size: 56),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context).renderFailed,
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnButton,
                      ),
                      onPressed: _run,
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}