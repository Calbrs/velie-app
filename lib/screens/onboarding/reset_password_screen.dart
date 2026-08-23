import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/primary_button.dart';
import '../../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone;
  const ResetPasswordScreen({super.key, required this.phone});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);

    try {
      await context.read<AuthProvider>().resetPassword(
        ownerPhone: widget.phone,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).passwordResetSuccess)),
      );
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).passwordResetFailed(e.toString())),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _pillDecoration(BuildContext context, String label, {Widget? suffixIcon}) {
    final theme = Theme.of(context).inputDecorationTheme;
    OutlineInputBorder getBorder(InputBorder? b) {
      if (b is OutlineInputBorder) return b.copyWith(borderRadius: BorderRadius.circular(999));
      return OutlineInputBorder(borderRadius: BorderRadius.circular(999));
    }
    return InputDecoration(
      labelText: label,
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
      appBar: AppBar(
        title: Text(l10n.newPasswordTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  l10n.setNewPassword,
                  style: AppTextStyles.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.passwordMinLength,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePass,
                  validator: (v) =>
                      v == null || v.length < 6 ? l10n.passwordTooShort : null,
                  decoration: _pillDecoration(
                    context, l10n.newPassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    )
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  validator: (v) {
                    if (v != _passwordController.text) return l10n.passwordsDoNotMatch;
                    return null;
                  },
                  decoration: _pillDecoration(
                    context, l10n.confirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    )
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: l10n.resetAndLogin,
                  onPressed: _submitting ? null : _submit,
                  loading: _submitting,
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}