import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Runs in a background isolate so the UI thread is never blocked by the
/// (CPU-heavy, pure-Dart) WebP re-encode.
Uint8List _toWebpInBackground(Uint8List bytes) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    return Uint8List.fromList(img.encodeWebP(decoded));
  } catch (_) {
    return bytes;
  }
}

/// Square 1:1 poster picker — image only (video is Phase 2).
/// Picks with [image_picker], crops square with [image_cropper], and always
/// re-encodes to WebP so the backend's webp-only
/// file-type filter (any picked format is accepted).
///
/// The picked image is shown immediately (raw bytes) while the WebP conversion
/// runs in the background, so picking never feels slow.
class PosterPickerField extends StatefulWidget {
  const PosterPickerField({
    super.key,
    this.imageBytes,
    this.onPicked,
    this.onRemoved,
  });

  final Uint8List? imageBytes;
  final void Function(Uint8List bytes, String name)? onPicked;
  final VoidCallback? onRemoved;

  @override
  State<PosterPickerField> createState() => PosterPickerFieldState();
}

class PosterPickerFieldState extends State<PosterPickerField> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;

  /// Raw bytes shown immediately while the background WebP conversion runs.
  Uint8List? _previewBytes;

  /// Re-encodes any image bytes to WebP off the UI thread so the backend's
  /// webp-only filter never rejects the upload.
  Future<Uint8List> _toWebp(Uint8List bytes) async {
    try {
      return await compute(_toWebpInBackground, bytes);
    } catch (_) {
      return bytes;
    }
  }

  Future<void> _pickFrom(ImageSource source) async {
    if (_busy) return;
    try {
      // Gallery picking needs NO runtime permission on any Android version:
      // image_picker uses the system Photo Picker (SAF), which hands us a
      // temporary grant to just the picked file. Do NOT request storage or
      // media permissions here — one of them is always ungrantable
      // (READ_EXTERNAL_STORAGE is capped at maxSdkVersion=32 in the manifest;
      // READ_MEDIA_IMAGES does not exist below API 33), so a combined check
      // can never pass and would block the picker from ever opening.
      if (Platform.isAndroid && source == ImageSource.camera) {
        await Permission.camera.request();
      }

      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        imageQuality: 90,
      );
      if (picked == null) return;

      setState(() {
        _busy = true;
        _previewBytes = null;
      });
      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty) return;

      // Show the picked image right away; convert to WebP in the background.
      setState(() => _previewBytes = bytes);
      final webp = await _toWebp(bytes);
      if (!mounted) return;
      setState(() => _previewBytes = null);
      widget.onPicked?.call(webp, '${_baseName(picked.name)}.webp');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Haikuweza kupakia picha. Jaribu tena.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> cropCurrent() async {
    if (widget.imageBytes == null || _busy) return;
    setState(() {
      _busy = true;
      _previewBytes = null;
    });
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_crop.webp');
      await tempFile.writeAsBytes(widget.imageBytes!);

      final cropped = await ImageCropper().cropImage(
        sourcePath: tempFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Kata Picha',
            toolbarColor: AppColors.buttonPrimary,
            toolbarWidgetColor: AppColors.textOnButton,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Kata Picha',
            aspectRatioLockEnabled: false,
          ),
        ]);

      if (cropped != null) {
        final bytes = await cropped.readAsBytes();
        if (bytes.isNotEmpty) {
          // Show the cropped result immediately; convert to WebP in background.
          setState(() => _previewBytes = bytes);
          final webp = await _toWebp(bytes);
          if (!mounted) return;
          setState(() => _previewBytes = null);
          widget.onPicked?.call(webp, 'cropped_${DateTime.now().millisecondsSinceEpoch}.webp');
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Haikuweza kukata picha. Jaribu tena.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _baseName(String name) {
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  Future<void> pickFromGallery() => _pickFrom(ImageSource.gallery);
  Future<void> pickFromCamera() => _pickFrom(ImageSource.camera);

  @override
  Widget build(BuildContext context) {
    // Prefer the just-picked preview so the image appears instantly; fall back
    // to the committed bytes from the provider.
    final displayBytes = _previewBytes ?? widget.imageBytes;
    final hasImage = displayBytes != null;
    return AspectRatio(
      aspectRatio: 1,
      child: hasImage
          ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(displayBytes, fit: BoxFit.contain),
                ),
                if (_busy)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : Material(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 44, color: AppColors.ash),
                  const SizedBox(height: 10),
                  Text('Hakuna Picha', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 4),
                  Text('1:1 (WhatsApp Status)', style: AppTextStyles.caption),
                ],
              ),
            ),
    );
  }
}