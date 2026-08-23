import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/primary_button.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phone;
  const VerifyOtpScreen({super.key, required this.phone});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  bool _submitting = false;
  int _secondsLeft = 50;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 50);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_otpController.text.trim().length < 4) return;
    setState(() => _submitting = true);

    try {
      await context.read<AuthProvider>().verifyOtp(
            ownerPhone: widget.phone,
            otp: _otpController.text.trim(),
          );
      if (!mounted) return;
      // Pass the phone forward so they can reset password
      if (mounted) context.push('/reset-password', extra: widget.phone);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).otpInvalid(e))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    try {
      await context.read<AuthProvider>().forgotPassword(ownerPhone: widget.phone);
      if (!mounted) return;
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).codeResent)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).cannotSendCode(e.toString())),
        ),
      );
    }
  }

  InputDecoration _pillDecoration(BuildContext context, String label) {
    final theme = Theme.of(context).inputDecorationTheme;
    OutlineInputBorder getBorder(InputBorder? b) {
      if (b is OutlineInputBorder) return b.copyWith(borderRadius: BorderRadius.circular(999));
      return OutlineInputBorder(borderRadius: BorderRadius.circular(999));
    }
    return InputDecoration(
      labelText: label,
      border: getBorder(theme.border),
      enabledBorder: getBorder(theme.enabledBorder),
      focusedBorder: getBorder(theme.focusedBorder),
      errorBorder: getBorder(theme.errorBorder),
      focusedErrorBorder: getBorder(theme.focusedErrorBorder),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      counterText: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifyOtpTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                l10n.enterOtp,
                style: AppTextStyles.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.otpSentTo(widget.phone),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                decoration: _pillDecoration(context, l10n.otpCode),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: l10n.verify,
                onPressed: _submitting ? null : _submit,
                loading: _submitting,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _secondsLeft > 0
                        ? l10n.codeExpiresIn(_secondsLeft)
                        : l10n.codeExpired,
                    style: AppTextStyles.caption.copyWith(
                      color: _secondsLeft > 0 ? AppColors.textSecondary : Colors.redAccent,
                    ),
                  ),
                  if (_secondsLeft == 0) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _resend,
                      child: Text(l10n.resend, style: TextStyle(color: AppColors.primary)),
                    )
                  ]
                ],
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}