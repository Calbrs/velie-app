import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/post_media_type.dart';
import '../../core/constants/post_status.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_time_formatter.dart';
import '../../models/post_schedule_model.dart';
import '../../providers/create_post_provider.dart';
import '../../providers/queue_provider.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/post/channel_icon.dart';

/// Full detail of a single post + actions (edit / delete / retry).
class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ensureLoaded();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeVideo(PostScheduleModel post) {
    if (_videoController != null) return;
    if (post.mediaType == PostMediaType.video) {
      if (post.imageUrl != null) {
        if (post.imageUrl!.startsWith('http')) {
          _videoController = VideoPlayerController.networkUrl(Uri.parse(post.imageUrl!));
        } else {
          _videoController = VideoPlayerController.file(File(post.imageUrl!));
        }
      }
      _videoController?.initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoController?.play();
        }
      });
      _videoController?.setLooping(true);
    }
  }

  Future<void> _ensureLoaded() async {
    final queue = context.read<QueueProvider>();
    if (queue.posts.any((p) => p.id == widget.postId)) {
      // Already listed: still refresh this one so the Status viewer count is live.
      await queue.refreshOne(widget.postId);
      return;
    }
    await queue.refresh();
  }

  PostScheduleModel? _post(QueueProvider queue) {
    return queue.posts.where((p) => p.id == widget.postId).firstOrNull;
  }

  Future<void> _edit(PostScheduleModel post) async {
    context.read<CreatePostProvider>().loadForEdit(post);
    if (mounted) context.go('/post/create');
  }

  Future<void> _delete(PostScheduleModel post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Futa Post?'),
        content: Text(
          post.isPending || post.isFailed
              ? 'Post hii itaondolewa kwenye foleni. Utendo huu hauwezi kutenduliwa.'
              : 'Status hii itafutwa pia kwenye WhatsApp. Utendo huu hauwezi kutenduliwa.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ghairi')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Futa', style: TextStyle(color: AppColors.statusFailed)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<QueueProvider>().delete(post.id);
    if (mounted) context.go('/queue');
  }

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueProvider>();
    final post = _post(queue);

    if (post != null && post.mediaType == PostMediaType.video && _videoController == null) {
      _initializeVideo(post);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/queue'),
        ),
        title: const Text('Maelezo ya Post'),
      ),
      body: post == null
          ? (queue.isLoading
              ? const LoadingView(label: 'Inapakia…')
              : _notFound(context))
          : RefreshIndicator(
              onRefresh: () => queue.refreshOne(widget.postId),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _hero(post),
                  const SizedBox(height: 20),
                  _infoCard(context, post),
                  const SizedBox(height: 20),
                  _actions(context, post, queue),
                ],
              ),
            ),
    );
  }

  Widget _notFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, color: AppColors.ash, size: 40),
          const SizedBox(height: 12),
          const Text('Post haikupatikana'),
          const SizedBox(height: 16),
          TextButton(onPressed: () => context.go('/queue'), child: const Text('Rudi Foleni')),
        ],
      ),
    );
  }

  Widget _hero(PostScheduleModel post) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 1,
            child: _buildHeroContent(post),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.all(8),
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
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroContent(PostScheduleModel post) {
    if (post.isText) {
      return Container(
        color: AppColors.primary.withValues(alpha: 0.15),
        alignment: Alignment.center,
        child: const Text(
          'T',
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      );
    }
    
    if (post.mediaType == PostMediaType.video) {
      if (_videoController != null && _videoController!.value.isInitialized) {
        return Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_videoController!),
          Positioned(
            bottom: 12,
            left: 54, // Avoid overlapping the type tag
            right: 12,
            child: Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _videoController!,
                    builder: (context, value, child) {
                      final duration = value.duration.inMilliseconds.toDouble();
                      final position = value.position.inMilliseconds.toDouble();
                      
                      return SliderTheme(
                        data: const SliderThemeData(
                          trackHeight: 6,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
                          overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: Colors.white24,
                        ),
                        child: Slider(
                          value: position.clamp(0.0, duration > 0 ? duration : 1.0),
                          max: duration > 0 ? duration : 1.0,
                          onChanged: (v) {
                            _videoController!.seekTo(Duration(milliseconds: v.toInt()));
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                    });
                  },
                  child: Icon(
                    _videoController!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _videoController!.value.volume == 0 ? _videoController!.setVolume(1.0) : _videoController!.setVolume(0.0);
                    });
                  },
                  child: Icon(
                    _videoController!.value.volume == 0 ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Container(
        color: AppColors.surfaceMuted,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
  }
    
    return post.localImage != null
        ? Image.memory(post.localImage!, fit: BoxFit.cover)
        : post.imageUrl != null
            ? Image.network(post.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => _heroFallback())
            : _heroFallback();
  }

  Widget _heroFallback() {
    return Container(
      color: AppColors.surfaceMuted,
      child: Center(
        child: Icon(Icons.image_outlined, color: AppColors.ash, size: 56),
      ),
    );
  }

  Widget _infoCard(BuildContext context, PostScheduleModel post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(post.caption.isEmpty ? '(Bila caption)' : post.caption, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
          Divider(color: AppColors.border, height: 1),
          _infoRow(context, 'Channel', Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ChannelIcon(post.channel, size: 16, enabled: true),
              const SizedBox(width: 6),
              Text(post.channel.label),
            ],
          )),
          _infoRow(context, 'Muda wa Kutuma', Text(DateTimeFormatter.full(post.scheduledTime))),
          _infoRow(context, 'Kurudia', Text(post.recurrenceSummary)),
          if (post.status == PostStatus.sent && post.publishedAt != null)
            _infoRow(
              context,
              'Muda Umelitumwa',
              Text(DateTimeFormatter.full(post.publishedAt)),
            ),
          _infoRow(context, 'Status', StatusBadge(status: post.status, trailingCheck: true)),
          if (post.status == PostStatus.sent && post.viewerCount != null)
            _infoRow(
              context,
              'Waliotazama (Viewers)',
              Text('${post.viewerCount}'),
            ),
          _infoRow(context, 'Majaribio (Retries)', Text('${post.retries}')),
          _infoRow(context, 'Iliundwa', Text(DateTimeFormatter.full(post.createdAt)), showDivider: false),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, Widget value, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(width: 16),
              Flexible(child: value),
            ],
          ),
        ),
        if (showDivider) Divider(color: AppColors.border, height: 1),
      ],
    );
  }

  Widget _actions(BuildContext context, PostScheduleModel post, QueueProvider queue) {
    final canEdit = post.isPending;
    final canRetry = post.isFailed;

    return Column(
      children: [
        if (canRetry)
          PrimaryButton(
            label: 'Jaribu Tena',
            icon: Icons.refresh,
            loading: queue.isBusy(post.id),
            onPressed: queue.isBusy(post.id) ? null : () => queue.retry(post.id),
          ),
        if (canRetry && (canEdit || !post.isDeleted)) const SizedBox(height: 10),
        if (canEdit) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _edit(post),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: AppColors.buttonPrimary,
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Hariri'),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (!post.isDeleted) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _delete(post),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: AppColors.statusFailed,
                side: const BorderSide(color: AppColors.statusFailed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Futa'),
            ),
          ),
        ],
      ],
    );
  }
}
