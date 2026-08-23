import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/post_status.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/queue_provider.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/post/post_list_card.dart';

/// Post queue with status filter.
class PostsQueueScreen extends StatefulWidget {
  const PostsQueueScreen({super.key});

  @override
  State<PostsQueueScreen> createState() => _PostsQueueScreenState();
}

class _PostsQueueScreenState extends State<PostsQueueScreen> {
  static const _filters = <(String, PostStatus?)>[
    ('Zote', null),
    ('Zinazosubiri', PostStatus.pending),
    ('Zilizotumwa', PostStatus.sent),
    ('Zimeshindwa', PostStatus.failed),
  ];

  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final queue = context.read<QueueProvider>();
    _searchController = TextEditingController(text: queue.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const Text('Foleni ya Posts'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: TextField(
                controller: _searchController,
                onChanged: queue.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Tafuta kwa caption...',
                  prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            _segmentedControl(context, queue),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => queue.refresh(),
                child: _buildList(context, queue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmentedControl(BuildContext context, QueueProvider queue) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: _filters.map((f) {
          final selected = queue.filter == f.$2;
          return Expanded(
            child: GestureDetector(
              onTap: () => queue.setFilter(f.$2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? AppColors.buttonPrimary : AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: selected ? AppColors.buttonPrimary : AppColors.border),
                ),
                child: Text(
                  f.$1,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.textOnButton : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList(BuildContext context, QueueProvider queue) {
    if (queue.isLoading && queue.posts.isEmpty) {
      return const SizedBox.shrink();
    }
    if (queue.error != null && queue.posts.isEmpty) {
      return EmptyStateView(
        icon: Icons.cloud_off,
        title: 'Haikuweza kupakia foleni',
        message: '${queue.error}',
        actionLabel: 'Jaribu Tena',
        onAction: () => queue.refresh(),
      );
    }
    if (queue.filteredPosts.isEmpty) {
      return EmptyStateView(
        icon: Icons.inbox_outlined,
        title: queue.posts.isEmpty
            ? 'Bado hujapanga post yoyote'
            : 'Hakuna post za hali hii',
        message: queue.posts.isEmpty
            ? 'Anza kutengeneza post yako ya kwanza'
            : 'Badilisha kichujio juu',
        actionLabel: null,
        onAction: null,
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: queue.filteredPosts.length,
      itemBuilder: (context, index) {
        final post = queue.filteredPosts[index];
        return PostListCard(
          post: post,
          isDashboardLayout: true,
          onTap: () => context.push('/queue/${post.id}'),
          retrying: queue.isBusy(post.id),
          onRetry: post.isFailed ? () => queue.retry(post.id) : null,
        );
      },
    );
  }
}
