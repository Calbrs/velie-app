import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/create_post_provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/post/poster_picker_field.dart';
import '../../../widgets/post/save_draft_dialog.dart';

/// Content upload — pick multiple images (1:1) and write unique captions.
class ImageStatusScreen extends StatefulWidget {
  const ImageStatusScreen({super.key});

  @override
  State<ImageStatusScreen> createState() => _ImageStatusScreenState();
}

class _ImageStatusScreenState extends State<ImageStatusScreen> {
  final GlobalKey<PosterPickerFieldState> _posterKey = GlobalKey();
  late final TextEditingController _captionController;
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();
    final draft = context.read<CreatePostProvider>();
    _captionController = TextEditingController(text: draft.caption);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _continue() {
    final draft = context.read<CreatePostProvider>();
    if (!draft.hasImage && !draft.isEditing) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chagua picha kwanza')));
      return;
    }
    context.push('/post/schedule');
  }

  InputDecoration _textFieldDecoration(BuildContext context) {
    final theme = Theme.of(context).inputDecorationTheme;
    OutlineInputBorder getBorder(InputBorder? b) {
      if (b is OutlineInputBorder) {
        return b.copyWith(borderRadius: BorderRadius.circular(24));
      }
      return OutlineInputBorder(borderRadius: BorderRadius.circular(24));
    }

    return InputDecoration(
      hintText: 'Andika maandishi ya post yako hapa…',
      border: getBorder(theme.border),
      enabledBorder: getBorder(theme.enabledBorder),
      focusedBorder: getBorder(theme.focusedBorder),
      errorBorder: getBorder(theme.errorBorder),
      focusedErrorBorder: getBorder(theme.focusedErrorBorder),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<CreatePostProvider>();

    if (draft.currentMultiImageIndex != _lastIndex) {
      _lastIndex = draft.currentMultiImageIndex;
      _captionController.text = draft.caption;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        confirmComposerBack(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => confirmComposerBack(context),
          ),
          title: Text(draft.isEditing ? 'Hariri Picha' : 'Status ya Picha'),
          actions: [
            IconButton(
              icon: const Icon(Icons.crop),
              onPressed: draft.imageBytes != null
                  ? () => _posterKey.currentState?.cropCurrent()
                  : null,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (draft.isEditing) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.statusPending.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Unaendelea kuhariri post ya awali. Picha ya awali itahifadhiwa usipochagua nyingine.',
                      style: TextStyle(
                        color: AppColors.statusPending,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                PosterPickerField(
                  key: _posterKey,
                  imageBytes: draft.imageBytes,
                  onPicked: (bytes, name) {
                    if (draft.multiImages.isEmpty) {
                      draft.setImage(bytes, name);
                    } else if (draft.currentMultiImageIndex ==
                        draft.multiImages.length) {
                      draft.addMultiImage(bytes, name);
                    } else {
                      draft.setImage(bytes, name);
                    }
                  },
                  onRemoved: draft.clearImage,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Andika Caption Yako',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _captionController,
                  maxLines: 3, // Reduced as requested
                  maxLength: 2200,
                  onChanged: draft.setCaption,
                  decoration: _textFieldDecoration(context),
                ),
                const SizedBox(height: 16),

                if (!draft.isEditing && draft.multiImages.isNotEmpty) ...[
                  const Text(
                    'Picha Zilizochaguliwa',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: draft.multiImages.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == draft.multiImages.length) {
                          return GestureDetector(
                            onTap: () {
                              draft.selectMultiImage(index);
                              _posterKey.currentState?.pickFromGallery();
                            },
                            child: Container(
                              width: 64,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: draft.currentMultiImageIndex == index
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }
                        final isSelected =
                            draft.currentMultiImageIndex == index;
                        return GestureDetector(
                          onTap: () => draft.selectMultiImage(index),
                          child: Stack(
                            children: [
                              Container(
                                width: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                    image: MemoryImage(
                                      draft.multiImages[index].bytes,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => draft.removeMultiImage(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    draft.selectMultiImage(draft.multiImages.length);
                    _posterKey.currentState?.pickFromCamera();
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/camera.png',
                        width: 24,
                        height: 24,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: draft.hasImage
                          ? _continue
                          : () {
                              draft.selectMultiImage(draft.multiImages.length);
                              _posterKey.currentState?.pickFromGallery();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: AppColors.textOnButton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        draft.hasImage
                            ? 'Endelea kwenye Ratiba'
                            : 'Chagua Picha',
                        style: AppTextStyles.buttonLabel,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
