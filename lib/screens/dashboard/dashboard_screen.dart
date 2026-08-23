import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/post_status.dart';
import '../../core/constants/post_media_type.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/business_model.dart';
import '../../models/post_schedule_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/create_post_provider.dart';
import 'package:velie_app/l10n/app_localizations.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/queue_provider.dart';
import '../../providers/update_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/post/post_list_card.dart';

/// Dashboard â€” dark theme (Charcoal & Gold).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final business = context.watch<AuthProvider>().business;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bofya tena ili kutoka')),
          );
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: _header(context, business),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _summaryCard(context, dashboard),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => dashboard.refresh(),
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  children: [
                    Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 16),
                    _recentPostsTimeline(context, dashboard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }



  Widget _createPostHeaderButton(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(Icons.add, color: AppColors.textPrimary, size: 20),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            backgroundColor: AppColors.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (sheetContext) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text('Chagua Aina ya Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    ListTile(
                      leading: Image.asset('assets/icons/video.png', width: 28, height: 28, color: AppColors.primary),
                      title: const Text('Video Status', style: TextStyle(fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        context.read<CreatePostProvider>().setMediaType(PostMediaType.video);
                        context.go('/post/create/video');
                      },
                    ),
                    ListTile(
                      leading: Image.asset('assets/icons/Text-icon.png', width: 28, height: 28, color: AppColors.primary),
                      title: const Text('Text Status', style: TextStyle(fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        context.read<CreatePostProvider>().setMediaType(PostMediaType.text);
                        context.go('/post/create/text');
                      },
                    ),
                    ListTile(
                      leading: Image.asset('assets/icons/camera.png', width: 28, height: 28, color: AppColors.primary),
                      title: const Text('Image Status', style: TextStyle(fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        context.read<CreatePostProvider>().setMediaType(PostMediaType.image);
                        context.go('/post/create/image');
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _profileAvatar(BuildContext context, BusinessModel? business) {
    final name = business?.name ?? '?';
    final initial = name.characters.isNotEmpty ? name.characters.first.toUpperCase() : '?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Center(
            child: Text(
              initial,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.statusSent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 2.5),
            ),
          ),
        ),
      ],
    );
  }

  /// Greeting + create shortcut + notification bell with a small gold
  /// accent indicator.
  Widget _header(BuildContext context, BusinessModel? business) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: _profileAvatar(context, business),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            business?.name ?? 'Mwambie',
            style: AppTextStyles.displayLarge.copyWith(fontSize: 22),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _createPostHeaderButton(context),
        const SizedBox(width: 8),
        _notificationButton(context),
      ],
    );
  }

  Widget _notificationButton(BuildContext context) {
    final updateProvider = context.watch<UpdateProvider>();
    final hasNotification = updateProvider.isDownloading || updateProvider.isReady;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 17),
            onPressed: () {
              context.push('/notifications');
            },
          ),
        ),
        if (hasNotification)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }


  /// Single horizontal card holding all three summary stats side by side,
  /// separated by thin vertical dividers (spec: "horizontal_single_card").
  Widget _summaryCard(BuildContext context, DashboardProvider dashboard) {
    final l10n = AppLocalizations.of(context);
    final items = <_SummaryItem>[
      _SummaryItem(l10n.pending, dashboard.pendingCount, AppColors.primary, status: PostStatus.pending),
      _SummaryItem(l10n.sent, dashboard.sentCount, AppColors.statusSent, status: PostStatus.sent),
      _SummaryItem(l10n.failed, dashboard.failedCount, AppColors.statusFailed, status: PostStatus.failed),
    ];

    final loading = dashboard.isLoading && dashboard.posts.isEmpty;
    final total = dashboard.pendingCount + dashboard.sentCount + dashboard.failedCount;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              context.read<QueueProvider>().setFilter(null);
              context.push('/queue');
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.totalStatus, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  if (loading)
                    Container(width: 20, height: 16, decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(4)))
                  else
                    Text('$total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Container(
                      width: 1,
                      height: 28,
                      color: AppColors.border,
                    ),
                  Expanded(child: _summaryItemView(context, items[i], loading)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItemView(BuildContext context, _SummaryItem item, bool loading) {
    return InkWell(
      onTap: () {
        if (item.status != null) {
          context.read<QueueProvider>().setFilter(item.status);
        }
        context.push('/queue');
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            if (loading)
              Container(
                width: 20,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            else
              Text(
                '${item.value}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Vertical timeline of recent posts â€” a thin connecting line on the
  /// left, each post shown as a dot + card with date/time, status and
  /// an overflow menu (spec: "vertical_timeline").
  Widget _recentPostsTimeline(BuildContext context, DashboardProvider dashboard) {
    if (dashboard.isLoading && dashboard.posts.isEmpty) {
      return const SizedBox(height: 40);
    }
    if (dashboard.posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, color: AppColors.ash, size: 40),
            const SizedBox(height: 12),
            Text(
              'Bado hakuna post',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final posts = dashboard.recentPosts;
    return Column(
      children: [
        for (var i = 0; i < posts.length; i++)
          _timelineRow(context, posts[i], isLast: i == posts.length - 1),
      ],
    );
  }

  Widget _timelineRow(BuildContext context, PostScheduleModel post, {required bool isLast}) {
    final statusColor = post.status.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // timeline rail: dot + connecting line
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 24),
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 1, color: AppColors.border),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PostListCard(
                post: post,
                isDashboardLayout: true,
                onTap: () => context.go('/queue/${post.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _SummaryItem {
  final String label;
  final int value;
  final Color color;
  final PostStatus? status;

  const _SummaryItem(this.label, this.value, this.color, {this.status});
}