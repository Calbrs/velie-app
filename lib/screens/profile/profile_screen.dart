import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:velie_app/l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_time_formatter.dart';
import '../../models/business_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/instance_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/primary_button.dart';

/// Business info + instance management + settings.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Toka?'),
        content: const Text('Utaondolewa kwenye akaunti yako ya Velie.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ghairi')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Toka', style: TextStyle(color: AppColors.statusFailed)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final instance = context.read<InstanceProvider>();
    final auth = context.read<AuthProvider>();
    await instance.disconnect();
    await auth.logout();
  }

  Future<void> _disconnect(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tenganisha WhatsApp?'),
        content: const Text('Namba hii ya WhatsApp itakatwa kwenye Velie. Posts zilizopangwa zitasimama.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ghairi')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tenganisha', style: TextStyle(color: AppColors.statusFailed)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<InstanceProvider>().disconnect();
  }

  void _showLinkedAccountsDrawer(BuildContext context, InstanceProvider inst) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Linked Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                _linkTile(
                  context: context,
                  title: 'WhatsApp (Primary number)',
                  icon: Icons.chat_bubble_outline,
                  isLinked: inst.isConnected,
                  onTap: () {
                    Navigator.pop(context);
                    if (inst.isConnected) {
                      _disconnect(context);
                    } else {
                      context.go('/connect');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _linkTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isLinked,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
      title: Text(title, style: AppTextStyles.titleMedium),
      trailing: isLinked ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
      onTap: onTap,
    );
  }

  void _showLanguageDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(context);
        final currentLocale = context.watch<LocaleProvider>().locale.languageCode;
        
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(l10n.selectLanguage, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                _LanguageTile(
                  title: l10n.languageEnglish,
                  localeCode: 'en',
                  currentLocale: currentLocale,
                  onTap: () {
                    context.read<LocaleProvider>().setLocale(const Locale('en'));
                    Navigator.pop(sheetContext);
                  },
                ),
                _LanguageTile(
                  title: l10n.languageSwahili,
                  localeCode: 'sw',
                  currentLocale: currentLocale,
                  onTap: () {
                    context.read<LocaleProvider>().setLocale(const Locale('sw'));
                    Navigator.pop(sheetContext);
                  },
                ),
                _LanguageTile(
                  title: l10n.languageChinese,
                  localeCode: 'zh',
                  currentLocale: currentLocale,
                  onTap: () {
                    context.read<LocaleProvider>().setLocale(const Locale('zh'));
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReportProblemDrawer(BuildContext context, BusinessModel? business) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _ReportProblemSheet(business: business),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final inst = context.watch<InstanceProvider>();
    final business = auth.business;

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
        title: const Text('Wasifu'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  _businessHero(context, business),
                  const SizedBox(height: 36),
                  _settingsList(context, business, inst),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusFailed.withValues(alpha: 0.1),
                      foregroundColor: AppColors.statusFailed,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    icon: const Icon(Icons.logout, size: 22),
                    label: Text('Toka kwenye akaunti', style: AppTextStyles.buttonLabel.copyWith(color: AppColors.statusFailed)),
                  ),
                ),
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Text(
                      'Velie v${snapshot.data!.version}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _businessHero(BuildContext context, BusinessModel? business) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.buttonPrimary, AppColors.buttonPrimary.withValues(alpha: 0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              (business?.name ?? '?').characters.first.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(business?.name ?? 'Biashara', style: AppTextStyles.titleMedium.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(business?.ownerPhone ?? '-', style: AppTextStyles.caption.copyWith(fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          'Created: ${business?.createdAt != null ? DateTimeFormatter.dayMonth(business!.createdAt) : 'Unknown'}',
          style: AppTextStyles.caption.copyWith(fontSize: 12, color: AppColors.ash),
        ),
      ],
    );
  }

  Widget _settingsList(BuildContext context, BusinessModel? business, InstanceProvider inst) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _settingsTile(
            icon: Icons.language,
            iconColor: AppColors.primary,
            title: 'Lugha / Language',
            onTap: () => _showLanguageDrawer(context),
          ),
          Divider(height: 1, color: AppColors.border),
          _settingsTile(
            icon: Icons.bug_report_outlined,
            iconColor: AppColors.statusPending,
            title: 'Ripoti Tatizo / Report a problem',
            hideChevron: true,
            onTap: () => _showReportProblemDrawer(context, business),
          ),
          Divider(height: 1, color: AppColors.border),
          _settingsTile(
            icon: Icons.link,
            iconColor: inst.isConnected ? AppColors.statusSent : AppColors.ash,
            title: 'Linked Accounts',
            subtitle: inst.isConnected ? 'WhatsApp imeunganishwa' : 'Haijaunganishwa',
            onTap: () => _showLinkedAccountsDrawer(context, inst),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? textColor,
    bool hideChevron = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: AppTextStyles.titleMedium.copyWith(
                      color: textColor ?? AppColors.textPrimary,
                    )
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),
            if (!hideChevron)
              Icon(Icons.chevron_right, color: AppColors.ash, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ReportProblemSheet extends StatefulWidget {
  final BusinessModel? business;
  const _ReportProblemSheet({this.business});

  @override
  State<_ReportProblemSheet> createState() => _ReportProblemSheetState();
}

class _ReportProblemSheetState extends State<_ReportProblemSheet> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      await Dio().post('${AppConstants.apiBaseUrl}/contacts', data: {
        'source': 'app',
        'name': widget.business?.name ?? 'Unknown',
        'contactInfo': widget.business?.ownerPhone ?? 'Unknown',
        'message': _controller.text,
        'metadata': {'businessId': widget.business?.id}
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ujumbe wako umetumwa kikamilifu.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imeshindwa kutuma ujumbe.')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ripoti Tatizo / Feedback', style: AppTextStyles.displayLarge.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Eleza tatizo lako hapa...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Tuma Ujumbe',
            onPressed: _isSubmitting ? null : _submit,
            loading: _isSubmitting,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.localeCode,
    required this.currentLocale,
    required this.onTap,
  });

  final String title;
  final String localeCode;
  final String currentLocale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = localeCode == currentLocale;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Text(title, style: AppTextStyles.titleMedium),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
      onTap: onTap,
    );
  }
}
