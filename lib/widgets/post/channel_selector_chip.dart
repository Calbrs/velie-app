import 'package:flutter/material.dart';

import '../../core/constants/post_channel.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'channel_icon.dart';

/// Pill chip for a post channel.
class ChannelSelectorChip extends StatelessWidget {
  const ChannelSelectorChip({
    super.key,
    required this.channel,
    required this.selected,
    required this.onTap,
  });

  final PostChannel channel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.buttonPrimary : AppColors.surface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.buttonPrimary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChannelIcon(channel, size: 18),
            const SizedBox(width: 6),
            Text(
              channel.label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.textOnButton : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
