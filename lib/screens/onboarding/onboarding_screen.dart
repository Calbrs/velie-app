import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/instance_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/onboarding_provider.dart';

/// One-time onboarding carousel shown right after the splash screen.
///
/// Walks the user through WhatsApp's own "Linked Devices" pairing flow
/// step by step: open the menu, tap Linked Devices, tap Link a Device,
/// then either scan the QR code or fall back to entering a phone-linking
/// code. Each step shows the exact WhatsApp screen the user will see.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;

  List<_OnboardingStep> _steps(AppLocalizations l10n) => [
    _OnboardingStep(
      title: l10n.onb1Title,
      body: l10n.onb1Body,
      imagePath: 'assets/images/onboarding_1.png',
    ),
    _OnboardingStep(
      title: l10n.onb2Title,
      body: l10n.onb2Body,
      imagePath: 'assets/images/onboarding_2.png',
    ),
    _OnboardingStep(
      title: l10n.onb3Title,
      body: l10n.onb3Body,
      imagePath: 'assets/images/onboarding_3.png',
    ),
    _OnboardingStep(
      title: l10n.onb4Title,
      body: l10n.onb4Body,
      imagePath: 'assets/images/onboarding_4.png',
    ),
    _OnboardingStep(
      title: l10n.onb5Title,
      body: l10n.onb5Body,
      imagePath: 'assets/images/onboarding_5.png',
    ),
  ];

  void _next(List<_OnboardingStep> steps) {
    if (_page < steps.length - 1) {
      setState(() {
        _page++;
      });
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) {
      setState(() {
        _page--;
      });
    }
  }

  Future<void> _finish() async {
    // Mark seen first so the screen never reappears on the next launch.
    await context.read<OnboardingProvider>().markSeen();
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final inst = context.read<InstanceProvider>();

    // Continue the normal flow from where the splash screen would have sent us.
    if (!auth.isAuthenticated) {
      context.go('/auth');
    } else if (!inst.hasInstance) {
      context.go('/connect');
    } else {
      context.go('/dashboard');
    }
  }

  void _skip() => _finish();

  void _showLanguagePicker(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.languagePickerTitle,
                style: AppTextStyles.displayLarge.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(l10n.swahiliLabel, style: AppTextStyles.bodyMedium),
                trailing: localeProvider.locale.languageCode == 'sw'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('sw'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(l10n.englishLabel, style: AppTextStyles.bodyMedium),
                trailing: localeProvider.locale.languageCode == 'en'
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = _steps(l10n);
    final step = steps[_page];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < -300) {
                  _next(steps);
                } else if (details.primaryVelocity! > 300) {
                  _back();
                }
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Animated Image Section
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Align(
                    key: ValueKey('image_$_page'),
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        _page == 4 ? 64 : 32, 
                        _page == 4 ? 80 : 48, 
                        _page == 4 ? 64 : 32, 
                        0,
                      ),
                      child: Image.asset(
                        step.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Text and Controls Section
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      24,
                      24,
                      24,
                      MediaQuery.of(context).padding.bottom + 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Animated Text Section
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            key: ValueKey('text_$_page'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                step.title,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.displayLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                step.body,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Bottom Controls
                        SizedBox(
                          height: 56, // Fixed height for reliable alignment
                          child: Stack(
                            children: [
                              // Dots (Center)
                              Align(
                                alignment: Alignment.center,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: _page > 0 ? 1.0 : 0.0,
                                  child: IgnorePointer(
                                    ignoring: _page == 0,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                        steps.length,
                                        (i) => AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          width: i == _page ? 24 : 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: i == _page
                                                ? AppColors.primary
                                                : AppColors.buttonDisabled,
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Back Arrow (Left)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                left: _page > 0 ? 0 : -60, // Slides in smoothly
                                top: 0,
                                bottom: 0,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: _page > 0 ? 1.0 : 0.0,
                                  child: IgnorePointer(
                                    ignoring: _page == 0,
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          onTap: _back,
                                          child: const Icon(Icons.arrow_back,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Next Button (Right Aligned, Expands to Full Width)
                              Align(
                                alignment: Alignment.centerRight,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                  width: _page == 0
                                      ? screenWidth - 48 // Full width minus padding
                                      : 72,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(999),
                                      onTap: () => _next(steps),
                                      child: Center(
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: _page == 0
                                              ? Text(
                                                  l10n.continueLabel,
                                                  key: const ValueKey('text'),
                                                  style: AppTextStyles
                                                      .displayLarge
                                                      .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                )
                                              : Icon(
                                                  _page == steps.length - 1
                                                      ? Icons.check
                                                      : Icons.arrow_forward,
                                                  key: const ValueKey('icon'),
                                                  color: Colors.white,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top Left Action (Language)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(999),
              ),
              child: TextButton(
                onPressed: () => _showLanguagePicker(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  context.watch<LocaleProvider>().locale.languageCode.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Top Right Action (Skip)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(999),
              ),
              child: TextButton(
                onPressed: _skip,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.skip,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.title,
    required this.body,
    required this.imagePath,
  });

  final String title;
  final String body;
  final String imagePath;
}