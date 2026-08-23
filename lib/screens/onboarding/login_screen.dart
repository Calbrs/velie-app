import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/phone_formatter.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/instance_provider.dart';
import '../../services/api_client.dart';
import '../../widgets/common/backend_offline_banner.dart';
import 'package:velie_app/l10n/app_localizations.dart';


/// Login screen â€” phone + password, with a link back to register.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  bool? _backendOnline;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBackend());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBackend() async {
    final online = await context.read<AuthProvider>().isBackendReachable();
    if (!mounted) return;
    setState(() => _backendOnline = online);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      final phone = PhoneFormatter.toE164(_phoneController.text);
      await context.read<AuthProvider>().login(
            ownerPhone: phone,
            password: _passwordController.text,
          );
      if (!mounted) return;

      final inst = context.read<InstanceProvider>();
      final hasInstance = await inst.checkHasInstance();
      if (!mounted) return;

      if (hasInstance) {
        context.go('/dashboard');
      } else {
        // Registered but not linked â€” ask what they want to do
        _showUnlinkedSheet();
      }
    } catch (e) {
      if (!mounted) return;
      _checkBackend();
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loginFailed(apiErrorMessage(e, l10n)))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showUnlinkedSheet() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.statusPending.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.link_off,
                  color: AppColors.statusPending,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nambari Haijaunganishwa',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Nambari yako imesajiliwa lakini haijaunganishwa na WhatsApp. Endelea na kuunganisha au sajili nambari nyingine?',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/connect');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.textOnButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text('Endelea na Kuunganisha', style: AppTextStyles.buttonLabel),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () async {
                    final router = GoRouter.of(context);
                    Navigator.pop(context);
                    await context.read<AuthProvider>().logout();
                    router.go('/auth');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.buttonPrimary,
                    side: BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text('Sajili Nambari Nyingine', style: AppTextStyles.buttonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _pillDecoration(BuildContext context, String label, {String? hint, String? prefixText, Widget? suffixIcon}) {
    final theme = Theme.of(context).inputDecorationTheme;
    OutlineInputBorder getBorder(InputBorder? b) {
      if (b is OutlineInputBorder) return b.copyWith(borderRadius: BorderRadius.circular(999));
      return OutlineInputBorder(borderRadius: BorderRadius.circular(999));
    }
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      suffixIcon: suffixIcon,
      border: getBorder(theme.border),
      enabledBorder: getBorder(theme.enabledBorder),
      focusedBorder: getBorder(theme.focusedBorder),
      errorBorder: getBorder(theme.errorBorder),
      focusedErrorBorder: getBorder(theme.focusedErrorBorder),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final cardWidth = isWide ? 480.0 : constraints.maxWidth;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: cardWidth),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/logo_velie.png',
                            width: 100,
                            height: 100,
                            errorBuilder: (_, _, _) => _fallbackLogo(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Ingia Velie',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayLarge,
                        ),
                        if (_backendOnline == false) ...[
                          const SizedBox(height: 20),
                          BackendOfflineBanner(onRetry: _checkBackend),
                        ],
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _pillDecoration(
                            context,
                            'Namba ya Simu',
                            prefixText: PhoneFormatter.prefix,
                            hint: '712 345 678',
                          ),
                          onChanged: (v) {
                            final formatted = PhoneFormatter.formatWhileTyping(v);
                            if (formatted != v) {
                              _phoneController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: formatted.length,
                                ),
                              );
                            }
                          },
                          validator: Validators.validateOwnerPhone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          decoration: _pillDecoration(
                            context,
                            'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.ash,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: Validators.validatePassword,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: Text(
                              'Umesahau password?',
                              style: TextStyle(
                                color: AppColors.buttonPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonPrimary,
                              foregroundColor: AppColors.textOnButton,
                              disabledBackgroundColor: AppColors.buttonDisabled,
                              disabledForegroundColor: AppColors.textOnButton,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: _submitting
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.textOnButton,
                                    ),
                                  )
                                : Text('Ingia', style: AppTextStyles.buttonLabel),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Huna akaunti?',
                              style: AppTextStyles.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => context.go('/auth'),
                              child: Text(
                                'Sajili',
                                style: TextStyle(
                                  color: AppColors.buttonPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _fallbackLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'V',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: AppColors.buttonPrimary,
          ),
        ),
      ),
    );
  }
}
