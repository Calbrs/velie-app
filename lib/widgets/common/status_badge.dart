import 'package:flutter/material.dart';

import '../../core/constants/post_status.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:velie_app/l10n/app_localizations.dart';

/// Pill-shaped status badge with status-tinted background.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.trailingCheck = false,
  });

  final PostStatus status;
  final bool trailingCheck;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.localizedLabel(AppLocalizations.of(context)),
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
          if (trailingCheck && status == PostStatus.sent) ...[
            const SizedBox(width: 3),
            Icon(Icons.check, size: 12, color: color),
          ],
        ],
      ),
    );
  }
}
