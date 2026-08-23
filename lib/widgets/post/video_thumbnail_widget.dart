import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_colors.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final Uint8List videoBytes;
  final double width;
  final double height;
  final double borderRadius;

  const VideoThumbnailWidget({
    super.key,
    required this.videoBytes,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 12.0,
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  @override
  void didUpdateWidget(VideoThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoBytes != widget.videoBytes) {
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    setState(() => _isLoading = true);
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/thumb_temp_${DateTime.now().millisecondsSinceEpoch}.mp4');
      await tempFile.writeAsBytes(widget.videoBytes);

      final thumbnail = await VideoThumbnail.thumbnailData(
        video: tempFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 256,
        quality: 75,
      );

      if (mounted) {
        setState(() {
          _thumbnailBytes = thumbnail;
          _isLoading = false;
        });
      }
      
      // Clean up temp file
      try {
        await tempFile.delete();
      } catch (_) {}
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: _thumbnailBytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(_thumbnailBytes!, fit: BoxFit.cover),
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Icon(Icons.play_circle_outline, color: Colors.white, size: 32),
                    ),
                  ),
                ],
              )
            : Container(
                color: AppColors.surfaceMuted,
                child: Center(
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.videocam_outlined, color: AppColors.ash),
                ),
              ),
      ),
    );
  }
}
