import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/create_post_provider.dart';
import '../../../providers/dashboard_provider.dart';

import '../../../widgets/common/section_header.dart';
import '../../../widgets/post/post_list_card.dart';
import '../../../widgets/post/save_draft_dialog.dart';

class TextStatusScreen extends StatefulWidget {
  const TextStatusScreen({super.key});

  @override
  State<TextStatusScreen> createState() => _TextStatusScreenState();
}

class _TextStatusScreenState extends State<TextStatusScreen> {
  late final TextEditingController _captionController;

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
      hintText: 'Andika status yako hapa…',
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
          title: Text(
            draft.isEditing ? 'Hariri Maandishi' : 'Status ya Maandishi',
          ),
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
                      'Unaendelea kuhariri post ya awali.',
                      style: TextStyle(
                        color: AppColors.statusPending,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _captionController,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 700,
                  onChanged: draft.setCaption,
                  decoration: _textFieldDecoration(context),
                ),
                const SizedBox(height: 20),
                Consumer<DashboardProvider>(
                  builder: (context, dashboard, child) {
                    final textPosts = dashboard.posts
                        .where((p) => p.isText)
                        .toList();
                    if (textPosts.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader('Recent text Statuses'),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: textPosts.take(5).length,
                          itemBuilder: (context, index) {
                            final post = textPosts[index];
                            return PostListCard(
                              post: post,
                              onTap: () {
                                draft.setCaption(post.caption);
                                _captionController.text = post.caption;
                              },
                              trailing: IconButton(
                                icon: Image.asset(
                                  'assets/icons/reload.png',
                                  color: AppColors.primary,
                                  width: 20,
                                ),
                                tooltip: 'Repost',
                                color: AppColors.primary,
                                onPressed: () {
                                  draft.setCaption(post.caption);
                                  _captionController.text = post.caption;
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: AppColors.textOnButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  'Endelea kwenye Ratiba',
                  style: AppTextStyles.buttonLabel,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
