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
import '../../widgets/common/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);

    final phone = PhoneFormatter.toE164(_phoneController.text);
    try {
      await context.read<AuthProvider>().forgotPassword(ownerPhone: phone);
      if (!mounted) return;
      // Navigate to OTP verification screen passing the phone
      if (mounted) context.push('/verify-otp', extra: phone);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).cannotSendCode(e.toString())),
        ),
      );
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
      appBar: AppBar(
        title: Text(l10n.forgotPassword),
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
                  l10n.recoverAccount,
                  style: AppTextStyles.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.recoverAccountBody,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _pillDecoration(
                    context,
                    l10n.phoneNumberOrUsername,
                    prefixText: '+255 ',
                    hint: '712 345 678',
                  ),
                  onChanged: (v) {
                    final formatted = PhoneFormatter.formatWhileTyping(v);
                    if (formatted != v) {
                      _phoneController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                  validator: Validators.validateOwnerPhone,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: l10n.sendOtp,
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