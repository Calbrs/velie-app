import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/phone_formatter.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/backend_offline_banner.dart';


/// Authentication screen — register with name, phone, password + confirm,
/// with a link to the login screen. Responsive: centered card on wide
/// screens, full-width form on phones.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  bool? _backendOnline;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBackend());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
      await context.read<AuthProvider>().register(
            name: _nameController.text.trim(),
            ownerPhone: phone,
            password: _passwordController.text,
          );
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      _checkBackend();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).registerFailed(e.toString()))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
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
                            width: 110,
                            height: 110,
                            errorBuilder: (_, _, _) => _fallbackLogo(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.registerTitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayLarge,
                        ),
                        if (_backendOnline == false) ...[
                          const SizedBox(height: 20),
                          BackendOfflineBanner(onRetry: _checkBackend),
                        ],
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: _pillDecoration(context, l10n.yourName),
                          validator: Validators.validateName,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _pillDecoration(
                            context,
                            l10n.phoneNumber,
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
                          textInputAction: TextInputAction.next,
                          decoration: _pillDecoration(
                            context,
                            l10n.password,
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
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          decoration: _pillDecoration(
                            context,
                            l10n.repeatPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.ash,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),
                          ),
                          validator: (v) => Validators.validateConfirmPassword(
                            v,
                            _passwordController.text,
                          ),
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 32),
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
                                : Text(l10n.register, style: AppTextStyles.buttonLabel),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.alreadyHaveAccount,
                              style: AppTextStyles.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: Text(
                                l10n.signIn,
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
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'V',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: AppColors.buttonPrimary,
          ),
        ),
      ),
    );
  }
}
