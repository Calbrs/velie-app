import 'package:flutter/material.dart';

import '../../core/constants/post_media_type.dart';
import '../../core/constants/post_status.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_time_formatter.dart';
import 'package:velie_app/l10n/app_localizations.dart';
import '../../models/post_schedule_model.dart';
import '../common/app_card.dart';
import '../common/status_badge.dart';
import 'channel_icon.dart';
import 'video_thumbnail_widget.dart';

/// Queue list item: thumbnail, truncated caption, channel, time, status badge.
class PostListCard extends StatelessWidget {
  const PostListCard({
    super.key,
    required this.post,
    this.onTap,
    this.onRetry,
    this.retrying = false,
    this.trailing,
    this.isCompactLayout = false,
    this.isDashboardLayout = false,
  });

  final PostScheduleModel post;
  final VoidCallback? onTap;
  final VoidCallback? onRetry;
  final bool retrying;
  final Widget? trailing;
  final bool isCompactLayout;
  final bool isDashboardLayout;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          if (!isCompactLayout || !post.isText) ...[
            _buildThumbnail(),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: isDashboardLayout
                ? _buildDashboardLayout(context)
                : _buildDefaultLayout(context),
          ),
          if (!isCompactLayout && !isDashboardLayout) ...[
            const SizedBox(width: 8),
            StatusBadge(status: post.status),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing!
            ] else if (post.status == PostStatus.failed && onRetry != null) ...[
              const SizedBox(width: 4),
              _retryButton(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDashboardLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: post.caption.length > 30 ? () => _showFullTextDrawer(context, post.caption) : null,
                child: Text(
                  post.caption.isEmpty ? '(Bila caption)' : post.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ChannelIcon(post.channel, size: 14, enabled: true),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                post.channel.label,
                style: AppTextStyles.caption.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              Icon(Icons.schedule, size: 12, color: AppColors.ash),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  DateTimeFormatter.short(post.scheduledTime ?? post.createdAt),
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.repeat, size: 12, color: AppColors.ash),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  post.localizedRecurrenceSummary(AppLocalizations.of(context)),
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              StatusBadge(status: post.status),
              if (trailing != null) ...[
                const SizedBox(width: 4),
                trailing!
              ] else if (post.status == PostStatus.failed && onRetry != null) ...[
                const SizedBox(width: 4),
                _retryButton(),
              ],
            ],
          ),
        ],
      );
  }

  Widget _buildDefaultLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompactLayout)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: post.caption.length > 30 ? () => _showFullTextDrawer(context, post.caption) : null,
                  child: Text(
                    post.caption.isEmpty ? '(Bila caption)' : post.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: post.status),
            ],
          )
        else
          GestureDetector(
            onTap: post.caption.length > 30 ? () => _showFullTextDrawer(context, post.caption) : null,
            child: Text(
              post.caption.isEmpty ? '(Bila caption)' : post.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ChannelIcon(post.channel, size: 14, enabled: true),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                post.channel.label,
                style: AppTextStyles.caption.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.schedule, size: 12, color: AppColors.ash),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                DateTimeFormatter.short(post.scheduledTime ?? post.createdAt),
                style: AppTextStyles.caption.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.repeat, size: 12, color: AppColors.ash),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                post.localizedRecurrenceSummary(AppLocalizations.of(context)),
                style: AppTextStyles.caption.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCompactLayout) ...[
              const Spacer(),
              if (trailing != null) trailing!
              else if (post.status == PostStatus.failed && onRetry != null)
                _retryButton(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _retryButton() {
    return retrying
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.statusFailed),
          )
        : TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: AppColors.statusFailed),
            child: const Text('Jaribu Tena'),
          );
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 64,
            height: 64,
            child: post.isText
                ? _textThumbnail()
                : (post.mediaType == PostMediaType.video && post.localImage != null)
                    ? VideoThumbnailWidget(videoBytes: post.localImage!)
                    : post.localImage != null
                        ? Image.memory(post.localImage!, fit: BoxFit.cover)
                        : post.imageUrl != null
                            ? Image.network(
                                post.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => post.mediaType == PostMediaType.video
                                    ? Container(color: AppColors.surfaceMuted, child: Icon(Icons.videocam, color: AppColors.ash))
                                    : _thumbnailFallback(),
                              )
                            : post.mediaType == PostMediaType.video
                                ? Container(color: AppColors.surfaceMuted, child: Icon(Icons.videocam, color: AppColors.ash))
                                : _thumbnailFallback(),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              post.isText
                  ? Icons.text_fields
                  : post.mediaType == PostMediaType.video
                      ? Icons.videocam
                      : Icons.image,
              size: 11,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _textThumbnail() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: const Text(
        'T',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _showFullTextDrawer(BuildContext context, String text) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Maandishi Kamili', style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbnailFallback() {
    return Container(
      color: AppColors.surfaceMuted,
      child: Icon(Icons.image_outlined, color: AppColors.ash, size: 24),
    );
  }
}
