import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/health_ai_logo.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(AppConstants.rememberMeKey) ?? false;
    if (saved) {
      final email = prefs.getString(AppConstants.savedEmailKey) ?? '';
      if (mounted) {
        setState(() {
          _rememberMe = saved;
          _emailCtrl.text = email;
        });
      }
    }
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.rememberMeKey, true);
      await prefs.setString(AppConstants.savedEmailKey, _emailCtrl.text.trim());
    }

    final success = await ref.read(authProvider.notifier).signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (success && mounted) {
      final user = ref.read(currentUserProvider);
      context.go(user?.isAdmin == true ? AppRoutes.admin : AppRoutes.home);
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
      body: Stack(
        children: [
          // ─── Background blob ──────────────────────
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        // ─── Header ───────────────
                        _buildHeader(isDark).animate().fadeIn(duration: 600.ms),
                        const SizedBox(height: 36),

                        // ─── Form ─────────────────
                        _buildForm(isDark, isLoading)
                            .animate(delay: 100.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(
                                begin: 0.15,
                                end: 0,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic),
                        const SizedBox(height: 24),

                        // ─── Remember + Forgot ────
                        _buildRememberForgot(isDark)
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 500.ms),
                        const SizedBox(height: 28),

                        // ─── Sign In Button ───────
                        AppButton(
                          label: 'Sign In',
                          onPressed: isLoading ? null : _signIn,
                          isLoading: isLoading,
                          style: AppButtonStyle.primary,
                          fullWidth: true,
                          height: 56,
                        )
                            .animate(delay: 300.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(
                                begin: 0.1,
                                end: 0,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic),
                        const SizedBox(height: 28),

                        // ─── Social Divider ───────
                        const OrDivider()
                            .animate(delay: 350.ms)
                            .fadeIn(duration: 400.ms),
                        const SizedBox(height: 20),

                        // ─── Social Buttons ───────
                        Row(
                          children: [
                            Expanded(
                              child: SocialLoginButton(
                                provider: SocialProvider.google,
                                onPressed: () => context.showInfoSnack(
                                    'Google sign-in requires OAuth configuration'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SocialLoginButton(
                                provider: SocialProvider.apple,
                                onPressed: () => context.showInfoSnack(
                                    'Apple sign-in requires OAuth configuration'),
                              ),
                            ),
                          ],
                        )
                            .animate(delay: 400.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0, duration: 400.ms),

                        const Spacer(),
                        // ─── Register link ────────
                        _buildRegisterLink(isDark)
                            .animate(delay: 500.ms)
                            .fadeIn(duration: 400.ms),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        // Logo
        const Row(
          children: [
            HealthAILogoChip(height: 34),
          ],
        ),
        const SizedBox(height: 32),
        // Titles
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: AppTextStyles.displaySmall(dark: isDark),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to continue your health journey',
                style: AppTextStyles.bodyMedium(dark: isDark),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isDark, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthTextField(
            controller: _emailCtrl,
            label: 'Email Address',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            focusNode: _emailFocus,
            prefixIcon: const Icon(Icons.mail_outline_rounded),
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            validator: Validators.email,
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: _passwordCtrl,
            label: 'Password',
            hint: '••••••••',
            obscureText: true,
            textInputAction: TextInputAction.done,
            focusNode: _passwordFocus,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            onFieldSubmitted: (_) => isLoading ? null : _signIn(),
            validator: (v) =>
                v == null || v.isEmpty ? 'Password is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRememberForgot(bool isDark) {
    return Row(
      children: [
        // Remember Me
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _rememberMe ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: _rememberMe
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight),
                    width: 1.5,
                  ),
                ),
                child: _rememberMe
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Remember me',
                style: AppTextStyles.labelMedium(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Forgot Password
        GestureDetector(
          onTap: () => context.push(AppRoutes.forgotPassword),
          child: Text(
            'Forgot Password?',
            style: AppTextStyles.labelMedium(color: AppColors.primary)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTextStyles.bodySmall(dark: isDark),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.register),
          child: Text(
            'Sign Up',
            style: AppTextStyles.bodySmall(color: AppColors.primary)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
