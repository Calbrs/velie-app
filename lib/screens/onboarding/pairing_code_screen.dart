import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/instance_provider.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/shimmer_box.dart';

/// Onboarding: Guided Connection Wizard
class PairingCodeScreen extends StatefulWidget {
  const PairingCodeScreen({super.key});

  @override
  State<PairingCodeScreen> createState() => _PairingCodeScreenState();
}

class _PairingCodeScreenState extends State<PairingCodeScreen> {
  InstanceProvider? _instanceProvider;
  bool _wasConnected = false;
  int _step = 0; // 0 = Intro, 1 = Guide & Code, 2 = Success

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<InstanceProvider>();
    if (provider != _instanceProvider) {
      _instanceProvider?.removeListener(_onInstanceChanged);
      _instanceProvider = provider;
      provider.addListener(_onInstanceChanged);
    }
  }

  @override
  void dispose() {
    _instanceProvider?.removeListener(_onInstanceChanged);
    super.dispose();
  }

  void _onInstanceChanged() {
    final inst = _instanceProvider;
    if (inst == null || !mounted) return;

    if (inst.isConnected && !_wasConnected) {
      _wasConnected = true;
      setState(() {
        _step = 2; // Success
      });
    }
  }

  Future<void> _startConnection() async {
    setState(() {
      _step = 1;
    });
    final inst = context.read<InstanceProvider>();
    if (inst.isConnected) return;
    try {
      await inst.ensurePairingCode();
    } catch (_) {}
  }

  void _finish() {
    if (context.canPop()) {
      context.pop(true);
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop(false);
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: _buildStepContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildIntro();
      case 1:
        return _buildGuide();
      case 2:
        return _buildSuccess();
      default:
        return const SizedBox();
    }
  }

  Widget _buildIntro() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.rocket_launch, color: AppColors.primary, size: 36),
        ),
        const SizedBox(height: 24),
        Text('Almost there 🚀', style: AppTextStyles.displayLarge),
        const SizedBox(height: 12),
        Text(
          'Velie needs to connect to your WhatsApp before it can publish your scheduled status.\n\nThis only takes about a minute.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 48),
        PrimaryButton(
          label: 'Connect WhatsApp',
          onPressed: _startConnection,
        ),
      ],
    );
  }

  Widget _buildGuide() {
    final inst = context.watch<InstanceProvider>();
    final code = inst.pairingCode;
    final isWaiting = inst.isLoading || inst.isStarting || code == null || code.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Connect WhatsApp', style: AppTextStyles.displayLarge),
        const SizedBox(height: 32),
        _buildGuideStep('1 / 3', 'Open WhatsApp on your phone'),
        const SizedBox(height: 20),
        _buildGuideStep('2 / 3', 'Go to Settings → Linked Devices → Link a Device'),
        const SizedBox(height: 20),
        _buildGuideStep('3 / 3', 'Enter this connection code:'),
        const SizedBox(height: 24),

        if (isWaiting)
          Column(
            children: [
              const ShimmerBox(width: double.infinity, height: 72, borderRadius: 16),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                  SizedBox(width: 12),
                  Text('Connecting securely...', style: TextStyle(color: AppColors.primary, fontSize: 14)),
                ],
              ),
            ],
          )
        else
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code.replaceAll(' ', '')));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code copied!')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    code,
                    style: AppTextStyles.displayLarge.copyWith(
                      letterSpacing: 4,
                      fontSize: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.copy, size: 24, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),

        const SizedBox(height: 48),
        if (inst.error != null) ...[
          Center(
            child: Text(inst.error!, style: TextStyle(color: AppColors.statusFailed, fontSize: 13), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Try Again',
            onPressed: () => inst.refreshPairingCode(),
          ),
        ] else if (!isWaiting)
          Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Text('Waiting for WhatsApp...', style: TextStyle(color: AppColors.primary, fontSize: 14)),
                ],
              ),
            ),
      ],
    );
  }

  Widget _buildGuideStep(String step, String instruction) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step,
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            instruction,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.statusSent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: AppColors.statusSent, size: 40),
        ),
        const SizedBox(height: 24),
        Text('WhatsApp Connected ✓', style: AppTextStyles.displayLarge),
        const SizedBox(height: 12),
        Text(
          "You're ready. Velie will handle the rest.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        const SizedBox(height: 48),
        PrimaryButton(
          label: 'Continue',
          onPressed: _finish,
        ),
      ],
    );
  }
}
