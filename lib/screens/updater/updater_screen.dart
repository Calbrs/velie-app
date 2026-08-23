import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/instance_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/update_provider.dart';

class UpdaterScreen extends StatefulWidget {
  const UpdaterScreen({super.key});

  @override
  State<UpdaterScreen> createState() => _UpdaterScreenState();
}

class _UpdaterScreenState extends State<UpdaterScreen> with SingleTickerProviderStateMixin {
  String? _apkPath;
  String? _latestVersion;
  bool _loading = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    
    _loadReadyUpdate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadReadyUpdate() async {
    final path = await UpdateProvider.getReadyApkPath();
    final version = await UpdateProvider.getReadyDisplayVersion();
    
    if (path == null || version == null) {
      // Something went wrong, skip
      if (mounted) _skipUpdate();
      return;
    }

    if (mounted) {
      setState(() {
        _apkPath = path;
        _latestVersion = version;
        _loading = false;
      });
      _animController.forward();
    }
  }

  Future<void> _installApk() async {
    final apk = _apkPath;
    if (apk == null) return;

    final file = File(apk);
    if (!await file.exists()) {
      // APK was deleted (e.g. temp dir cleared) — go back to dashboard
      await UpdateProvider.clearReadyUpdate();
      if (mounted) _skipUpdate();
      return;
    }

    await OpenFilex.open(apk, type: 'application/vnd.android.package-archive');
  }

  void _skipUpdate() {
    final auth = context.read<AuthProvider>();
    final inst = context.read<InstanceProvider>();
    final onboarding = context.read<OnboardingProvider>();
    
    if (!onboarding.isSeen) {
      context.go('/onboarding');
      return;
    }

    if (!auth.isAuthenticated) {
      context.go('/auth');
    } else if (!inst.hasInstance) {
      context.go('/connect');
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Glow (Like Web UI)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 120, spreadRadius: 120),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: _loading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : _buildUpdateUI(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateUI() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(),
              Image.asset('assets/images/logo_velie.png', width: 120, height: 120),
              const SizedBox(height: 24),
              Text(
                'Toleo Jipya Linapatikana',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayLarge.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 12),
              Text(
                'Velie v$_latestVersion ipo tayari. Pakua sasa ili kufurahia maboresho haya:',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 32),
              
              // What's new content
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeatureRow(Icons.bolt, 'Utendaji wa haraka zaidi'),
                    const SizedBox(height: 16),
                    _buildFeatureRow(Icons.bug_report, 'Marekebisho ya makosa (Bug fixes)'),
                    const SizedBox(height: 16),
                    _buildFeatureRow(Icons.palette, 'Muonekano mpya na mzuri zaidi'),
                  ],
                ),
              ),
              
              const Spacer(flex: 2),
              Column(
                children: [
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _installApk,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: AppColors.textOnButton,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: Text('Sasisha Sasa (Update)', style: AppTextStyles.buttonLabel.copyWith(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _skipUpdate,
                    child: Text(
                      'Ruka kwa sasa',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
