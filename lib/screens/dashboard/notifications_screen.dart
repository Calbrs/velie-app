import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/update_provider.dart';
import '../../widgets/common/app_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final updateProvider = context.watch<UpdateProvider>();
    final showUpdateCard = updateProvider.isDownloading || updateProvider.isReady;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.back(context),
        ),
        title: Text(AppLocalizations.of(context).notificationsAppBarTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (showUpdateCard)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: InkWell(
                  onTap: updateProvider.isReady ? () => context.go('/updater') : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 0.5),
                          ),
                          child: Icon(
                            updateProvider.isReady ? Icons.system_update : Icons.cloud_download,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                updateProvider.isReady
                                    ? AppLocalizations.of(context).updateReadyTitle
                                    : AppLocalizations.of(context).updateDownloadingTitle,
                                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              if (updateProvider.isDownloading)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: updateProvider.progress,
                                    backgroundColor: AppColors.surfaceMuted,
                                    color: AppColors.primary,
                                    minHeight: 6,
                                  ),
                                )
                              else if (updateProvider.isReady)
                                Text(
                                  AppLocalizations.of(context).updateReadySubtitle,
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                        if (updateProvider.isReady) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
          if (!showUpdateCard)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_off_outlined, color: AppColors.textSecondary, size: 48),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context).noNotificationsTitle,
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).noNotificationsBody,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
