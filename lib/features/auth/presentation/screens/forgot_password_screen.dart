import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ref
        .read(authProvider.notifier)
        .sendPasswordReset(_emailCtrl.text.trim());

    if (success && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final isDark = context.isDark;

    ref.listen(authProvider, (_, next) {
      if (next is AuthError) {
        context.showErrorSnack(next.message);
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // ─── Back ─────────────────────────────
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardSecondaryDark
                        : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

              const SizedBox(height: 32),

              if (_emailSent) ...[
                // ─── Success state ─────────────────
                _buildSuccessState(isDark),
              ] else ...[
                // ─── Form state ────────────────────
                _buildFormState(isDark, isLoading),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormState(bool isDark, bool isLoading) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Forgot Password?',
                  style: AppTextStyles.displaySmall(dark: isDark))
              .animate(delay: 50.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, end: 0, duration: 500.ms),
          const SizedBox(height: 8),
          Text(
            "Enter your email and we'll send you a link to reset your password.",
            style: AppTextStyles.bodyMedium(dark: isDark),
          )
              .animate(delay: 100.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, end: 0, duration: 500.ms),
          const SizedBox(height: 36),
          Form(
            key: _formKey,
            child: AuthTextField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              textInputAction: TextInputAction.done,
              validator: Validators.email,
              onFieldSubmitted: (_) => isLoading ? null : _sendReset(),
            ),
          )
              .animate(delay: 150.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms),
          const SizedBox(height: 28),
          AppButton(
            label: 'Send Reset Link',
            onPressed: isLoading ? null : _sendReset,
            isLoading: isLoading,
            style: AppButtonStyle.primary,
            fullWidth: true,
            height: 56,
            leading:
                const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildSuccessState(bool isDark) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success icon
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: AppColors.primary,
              size: 44,
            ),
          )
              .animate()
              .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 600.ms,
                  curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 28),
          Text('Check Your Email',
                  style: AppTextStyles.headlineMedium(dark: isDark),
                  textAlign: TextAlign.center)
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.15, end: 0),

          const SizedBox(height: 10),
          Text(
            "We've sent a password reset link to\n${_emailCtrl.text.trim()}",
            style: AppTextStyles.bodyMedium(dark: isDark),
            textAlign: TextAlign.center,
          )
              .animate(delay: 300.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 40),
          AppButton(
            label: 'Back to Sign In',
            onPressed: () => context.pop(),
            style: AppButtonStyle.secondary,
            fullWidth: true,
            height: 54,
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}
