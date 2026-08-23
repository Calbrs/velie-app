import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Animated pill bottom navigation — Dashboard · Tengeneza · Foleni · Wasifu.
class PillBottomNav extends StatelessWidget {
  const PillBottomNav({super.key, required this.currentIndex});

  /// 0 = dashboard, 1 = tengeneza, 2 = foleni, 3 = wasifu.
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final labels = const ['Foleni', 'Tengeneza', 'Foleni', 'Wasifu'];
    final destinations = const ['/dashboard', '/post/create', '/queue', '/profile'];
    final outlineIcons = const [Icons.dashboard_outlined, Icons.add_circle_outline, Icons.format_list_bulleted, Icons.person_outline];
    final filledIcons = const [Icons.dashboard, Icons.add_circle, Icons.format_list_bulleted, Icons.person];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        height: 64,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: List.generate(4, (i) {
            final selected = i == currentIndex;
            return Expanded(
              child: _NavItem(
                label: labels[i],
                icon: selected ? filledIcons[i] : outlineIcons[i],
                selected: selected,
                onTap: () {
                  if (!selected) context.go(destinations[i]);
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? AppColors.buttonPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.textOnButton : AppColors.ash,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: selected ? AppColors.textOnButton : AppColors.ash,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
