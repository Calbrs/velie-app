import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/instance_provider.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/shimmer_box.dart';

/// Onboarding, hatua 2 — connect WhatsApp via a pairing code.
///
/// Displays:
///   - Shimmer while waiting for worker + code generation
///   - Code card when code is ready (user copies & enters on phone)
///   - Connected card on success, then navigates to dashboard
class PairingCodeScreen extends StatefulWidget {
  const PairingCodeScreen({super.key});

  @override
  State<PairingCodeScreen> createState() => _PairingCodeScreenState();
}

class _PairingCodeScreenState extends State<PairingCodeScreen> {
  InstanceProvider? _instanceProvider;
  bool _wasConnected = false;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ensure();
    });
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imeunganishwa! ✓'),
          backgroundColor: AppColors.statusSent,
        ),
      );
      Future.delayed(AppConstants.connectedCelebrationDelay, () {
        if (mounted) context.go('/dashboard');
      });
    }
  }

  Future<void> _ensure() async {
    final inst = context.read<InstanceProvider>();
    if (inst.isConnected) return;
    try {
      await inst.ensurePairingCode();
    } catch (_) {}
  }

  Future<void> _refresh() async {
    final inst = context.read<InstanceProvider>();
    try {
      await inst.refreshPairingCode();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Haikupata msimbo mpya: $e')),
      );
    }
  }

  Future<void> _copy(String code) async {
    await Clipboard.setData(ClipboardData(text: code.replaceAll(' ', '')));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Msimbo umenakiliwa')),
    );
  }

  void _showHelp() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jinsi ya Kuunganisha', style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              const _HelpStep(index: 1, text: 'Fungua WhatsApp kwenye simu yako'),
              const _HelpStep(index: 2, text: 'Nenda kwenye: Mipangilio → Vifaa Vilivyounganishwa (Linked Devices)'),
              const _HelpStep(index: 3, text: 'Bonyeza "Unganisha Kifaa" (Link a Device)'),
              const _HelpStep(index: 4, text: 'Chagua "Unganisha kwa Namba ya Simu" (Link with Phone Number)'),
              const _HelpStep(index: 5, text: 'Ingiza msimbo ulioko hapa kwenye WhatsApp'),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Nimeelewa',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Toka?'),
        content: const Text('Je, una uhakika unataka kufuta usajili na kurudi mwanzoni?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ghairi')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Toka', style: TextStyle(color: AppColors.statusFailed)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final inst = context.watch<InstanceProvider>();
    final code = inst.pairingCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unganisha WhatsApp'),
        actions: [
          TextButton(
            onPressed: _logout,
            child: Text('Toka', style: TextStyle(color: AppColors.ash)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Main content area: connected, code, or loading
              if (inst.isConnected)
                _connectedCard()
              else if (code != null && code.isNotEmpty)
                _codeCard(code)
              else
                _loadingOrError(inst),

              const Spacer(),

              // Bottom actions
              if (!inst.isConnected) ...[
                PrimaryButton(
                  label: 'Pata Msimbo Mpya',
                  loading: inst.isLoading,
                  onPressed: inst.isLoading ? null : _refresh,
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: _showHelp,
                    child: Text('Msaada', style: TextStyle(color: AppColors.ash)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _connectedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.statusSent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.statusSent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppColors.statusSent, size: 34),
          ),
          const SizedBox(height: 12),
          Text('Imeunganishwa ✓', style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Unaelekezwa kwenye dashibodi…',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _codeCard(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Text(
            'MSIMBO WA KUUNGANISHA',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          SelectableText(
            code,
            style: AppTextStyles.pairingCode,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => _copy(code),
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Nakili'),
          ),
        ],
      ),
    );
  }

  Widget _loadingOrError(InstanceProvider inst) {
    if (inst.error != null || inst.isRateLimited) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.statusFailed.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, color: AppColors.statusFailed, size: 36),
            const SizedBox(height: 12),
            Text(
              inst.isRateLimited ? 'Umefikia kikomo' : 'Hatuwezi kuunganishwa na seva',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              '${inst.error}',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Jaribu Tena', onPressed: _ensure),
          ],
        ),
      );
    }

    // Loading shimmer while worker boots + code generates
    return const PairingCodeShimmer();
  }
}

class _HelpStep extends StatelessWidget {
  const _HelpStep({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.buttonPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
