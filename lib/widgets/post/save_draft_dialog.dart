import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/create_post_provider.dart';

/// Intercepts "back" from the composer screens (text / image / video). When
/// creating a new post with leftover edits that haven't been scheduled, asks the
/// user whether to save them as a draft before leaving or to just leave. Either
/// way the back action then proceeds. Editing an existing post goes straight
/// back — the original post stays on the server.
Future<void> confirmComposerBack(BuildContext context) async {
  final draft = context.read<CreatePostProvider>();
  if (draft.isEditing) {
    AppRouter.back(context);
    return;
  }
  final hasEdits = draft.hasImage || draft.hasCaption;
  if (!hasEdits) {
    AppRouter.back(context);
    return;
  }

  final save = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'Hifadhi kama Rasimu?',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'Una mabadiliko ambayo hayajahifadhiwa. Je, ungependa kuyahifadhi '
        'kama rasimu kabla ya kuondoka?',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Ghairi', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(
            'Hifadhi kama Rasimu',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    ),
  );

  if (save == null || !context.mounted) return;
  if (save) {
    await context.read<CreatePostProvider>().saveAsDraft();
    if (!context.mounted) return;
  }
  context.read<CreatePostProvider>().reset();
  if (!context.mounted) return;
  AppRouter.back(context);
}
