import 'package:flutter/material.dart';
import 'package:velie_app/l10n/app_localizations.dart';

import '../theme/app_colors.dart';

/// Mirrors `posts_schedule.status` (pending / sent / failed / deleted).
enum PostStatus {
  pending,
  sent,
  failed,
  deleted,
  unknown;

  static PostStatus fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return PostStatus.pending;
      case 'sent':
        return PostStatus.sent;
      case 'failed':
        return PostStatus.failed;
      case 'deleted':
        return PostStatus.deleted;
      default:
        return PostStatus.unknown;
    }
  }

  String get apiValue => switch (this) {
        PostStatus.pending => 'pending',
        PostStatus.sent => 'sent',
        PostStatus.failed => 'failed',
        PostStatus.deleted => 'deleted',
        PostStatus.unknown => 'unknown',
      };

  String localizedLabel(AppLocalizations l10n) => switch (this) {
        PostStatus.pending => l10n.statusPending,
        PostStatus.sent => l10n.statusSent,
        PostStatus.failed => l10n.statusFailed,
        PostStatus.deleted => l10n.statusDeleted,
        PostStatus.unknown => l10n.statusUnknown,
      };

  Color get color => switch (this) {
        PostStatus.pending => AppColors.statusPending,
        PostStatus.sent => AppColors.statusSent,
        PostStatus.failed => AppColors.statusFailed,
        PostStatus.deleted => AppColors.ash,
        PostStatus.unknown => AppColors.ash,
      };
}
