import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'device_audio_picker_sheet.dart';

/// Background-music picker for video posts.
///
/// Opens an in-app drawer (85% height) listing the songs on the user's device
/// instead of the system file selector. The drawer supports searching by typing
/// and lets the user trim the chosen track before it is attached to the video.
class AudioPickerField extends StatefulWidget {
  const AudioPickerField({
    super.key,
    this.audioPath,
    this.audioName,
    this.audioSizeBytes,
    this.onPicked,
    this.onRemoved,
  });

  /// Absolute path of the currently selected audio, or null when empty.
  final String? audioPath;

  /// Display name shown when a track has been picked.
  final String? audioName;

  /// Size in bytes used to render the track size label.
  final int? audioSizeBytes;

  /// Called with the picked track's path (and its display friendly name).
  final void Function(String path, String name)? onPicked;

  /// Called when the user removes the selected track.
  final VoidCallback? onRemoved;

  @override
  State<AudioPickerField> createState() => _AudioPickerFieldState();
}

class _AudioPickerFieldState extends State<AudioPickerField> {
  bool _busy = false;

  Future<void> _pick() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final picked = await showDeviceAudioPicker(context);
      if (picked == null) return;
      widget.onPicked?.call(picked.path, picked.name);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Haikuweza kupakia muziki. Jaribu tena.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _remove() {
    if (_busy) return;
    widget.onRemoved?.call();
  }

  String get _sizeLabel {
    final bytes = widget.audioSizeBytes;
    if (bytes == null || bytes <= 0) return '';
    if (bytes >= 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context) {
    final hasAudio = widget.audioPath != null;

    if (_busy) {
      return Container(
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.buttonPrimary),
        ),
      );
    }

    if (!hasAudio) {
      return Material(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: _pick,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.music_note_outlined, size: 26, color: AppColors.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ongeza Muziki wa Usuli', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Audio pekee · mp3/m4a/wav',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.add_circle_outline, color: AppColors.primary),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.music_note, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.audioName ?? 'Muziki uliochaguliwa',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (_sizeLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(_sizeLabel, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Badilisha muziki',
            onPressed: _pick,
            icon: const Icon(Icons.refresh, size: 20),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'Ondoa muziki',
            onPressed: _remove,
            icon: const Icon(Icons.close, size: 20),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}