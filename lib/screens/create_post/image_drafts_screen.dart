import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/post_media_type.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/create_post_provider.dart';
import '../../services/draft_service.dart';

class ImageDraftsScreen extends StatefulWidget {
  const ImageDraftsScreen({super.key});

  @override
  State<ImageDraftsScreen> createState() => _ImageDraftsScreenState();
}

class _ImageDraftsScreenState extends State<ImageDraftsScreen> {
  final DraftService _draftService = DraftService();
  late Future<List<LocalDraft>> _draftsFuture;
  final Map<int, Uint8List?> _thumbnailCache = {};
  Timer? _syncTimer;
  int? _accountId;

  @override
  void initState() {
    super.initState();
    _accountId = context.read<AuthProvider>().businessId;
    _loadDrafts();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() => _loadDrafts());
      }
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  void _loadDrafts() {
    final account = _accountId;
    _draftsFuture = (account == null ? Future.value(const <LocalDraft>[]) : _draftService.listForAccount(account)).then((
      drafts,
    ) {
      return drafts.where((d) => d.mediaType == PostMediaType.image).toList();
    });
  }

  Future<Uint8List?> _getThumbnail(LocalDraft draft) async {
    if (_thumbnailCache.containsKey(draft.id)) {
      return _thumbnailCache[draft.id];
    }
    if (draft.localMediaPath == null) return null;

    try {
      final bytes = await File(draft.localMediaPath!).readAsBytes();
      _thumbnailCache[draft.id] = bytes;
      return bytes;
    } catch (e) {
      debugPrint('Draft thumbnail error: $e');
      _thumbnailCache[draft.id] = null;
      return null;
    }
  }

  void _startNewImage() async {
    context.read<CreatePostProvider>().reset();
    context.read<CreatePostProvider>().setMediaType(PostMediaType.image);
    context.push('/post/create/image/editor');
  }

  void _openDraft(LocalDraft draft) async {
    await context.read<CreatePostProvider>().loadLocalDraft(draft);
    if (mounted) {
      context.push('/post/create/image/editor').then((_) {
        if (mounted) setState(() => _loadDrafts());
      });
    }
  }

  void _deleteDraft(LocalDraft draft) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Futa Rasimu', style: TextStyle(color: Colors.white)),
        content: const Text('Je, una uhakika unataka kufuta rasimu hii?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ghairi', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Futa', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      _thumbnailCache.remove(draft.id);
      final account = _accountId;
      if (account != null) {
        await _draftService.delete(draft.id, accountId: account);
      }
      if (mounted) setState(() => _loadDrafts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => AppRouter.back(context),
        ),
        title: const Text(
          'Image Drafts',
          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<LocalDraft>>(
                future: _draftsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  final drafts = snapshot.data ?? [];
                  if (drafts.isEmpty) {
                    return const Center(
                      child: Text(
                        'No image drafts found',
                        style: TextStyle(color: Colors.white54, fontSize: 15),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: drafts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final draft = drafts[index];
                      return _buildDraftCard(draft);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startNewImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.textOnButton,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text('Tengeneza Picha Mpya', style: AppTextStyles.buttonLabel),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraftCard(LocalDraft draft) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final dateString = dateFormat.format(draft.createdAt);

    return GestureDetector(
      onTap: () => _openDraft(draft),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 100,
              height: 100,
              child: FutureBuilder<Uint8List?>(
                future: _getThumbnail(draft),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      color: Colors.black26,
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      ),
                    );
                  }
                  if (snapshot.data != null) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      cacheWidth: 100, // optimize memory usage
                    );
                  }
                  return Container(
                    color: Colors.black26,
                    child: const Icon(Icons.image, color: Colors.white38),
                  );
                },
              ),
            ),
            
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dateString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      draft.caption.isNotEmpty ? draft.caption : 'No caption',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Delete and Arrow
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white54),
                    onPressed: () => _deleteDraft(draft),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white38),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
