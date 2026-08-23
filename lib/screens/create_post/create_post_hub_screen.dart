import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/post_media_type.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/create_post_provider.dart';

/// Tengeneza hub — the landing screen for the bottom-nav "Tengeneza" tab and a
/// valid destination for `/post/create`, offering the three status types.
///
/// This screen exists so that back buttons and the create tab never resolve to
/// a dead `/post/create` path (which previously caused "no path found").
class CreatePostHubScreen extends StatelessWidget {
  const CreatePostHubScreen({super.key});

  void _open(BuildContext context, PostMediaType type, String path) {
    context.read<CreatePostProvider>().setMediaType(type);
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => AppRouter.back(context),
        ),
        title: Text(
          l10n.createPostAppBarTitle,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l10n.selectStatusType, style: AppTextStyles.titleMedium),
            const SizedBox(height: 6),
            Text(
              l10n.createPostSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _option(
              context,
              icon: Icons.videocam_outlined,
              title: l10n.videoStatus,
              subtitle: l10n.videoStatusSubtitle,
              color: AppColors.primary,
              onTap: () => _open(context, PostMediaType.video, '/post/create/video'),
            ),
            const SizedBox(height: 12),
            _option(
              context,
              icon: Icons.text_fields,
              title: l10n.textStatus,
              subtitle: l10n.textStatusSubtitle,
              color: AppColors.statusSent,
              onTap: () => _open(context, PostMediaType.text, '/post/create/text'),
            ),
            const SizedBox(height: 12),
            _option(
              context,
              icon: Icons.image_outlined,
              title: l10n.imageStatus,
              subtitle: l10n.imageStatusSubtitle,
              color: AppColors.statusPending,
              onTap: () => _open(context, PostMediaType.image, '/post/create/image'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.ash, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
