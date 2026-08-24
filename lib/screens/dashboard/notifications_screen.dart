import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/update_provider.dart';
import '../../services/api_client.dart';
import '../../services/message_service.dart';
import '../../widgets/common/app_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final MessageService _service = MessageService();
  late final Future<List<AdminMessageModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<AdminMessageModel>> _load() async {
    final messages = await _service.listMessages();
    // Soft-hide: anything already viewed stays hidden for this viewer.
    return messages.where((m) => !m.viewed).toList();
  }

  Future<void> _openMessage(AdminMessageModel message) async {
    final l10n = AppLocalizations.of(context);
    try {
      await _service.markViewed(message.id);
      setState(() {
        _future = _load();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorMessage(e, l10n))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateProvider = context.watch<UpdateProvider>();
    final showUpdateCard = updateProvider.isDownloading || updateProvider.isReady;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.back(context),
        ),
        title: Text(l10n.notificationsAppBarTitle),
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

          Expanded(
            child: FutureBuilder<List<AdminMessageModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.cloud_off_outlined,
                              color: AppColors.textSecondary, size: 48),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          apiErrorMessage(snapshot.error!, l10n),
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => setState(() => _future = _load()),
                          icon: const Icon(Icons.refresh, color: AppColors.primary),
                          label: Text(
                            l10n.retry,
                            style: AppTextStyles.buttonLabel.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data ?? <AdminMessageModel>[];
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.notifications_off_outlined,
                              color: AppColors.textSecondary, size: 48),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.noNotificationsTitle,
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noNotificationsBody,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return AppCard(
                      child: InkWell(
                        onTap: () => _openMessage(message),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border, width: 0.5),
                                ),
                                child: Icon(
                                  message.isDirect ? Icons.support_agent : Icons.campaign_outlined,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if ((message.title ?? '').isNotEmpty)
                                      Text(
                                        message.title!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.titleMedium
                                            .copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      message.message,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _formatDate(message.createdAt),
                                      style: AppTextStyles.caption
                                          .copyWith(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}
