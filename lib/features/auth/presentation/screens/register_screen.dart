import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/health_ai_logo.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _ageFocus = FocusNode();

  String? _selectedGender;
  double _passwordStrength = 0;
  String _strengthLabel = '';
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _ageCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final strength = Validators.passwordStrength(_passwordCtrl.text);
    double value;
    String label;

    switch (strength) {
      case PasswordStrength.empty:
        value = 0;
        label = '';
        break;
      case PasswordStrength.weak:
        value = 0.25;
        label = 'Weak';
        break;
      case PasswordStrength.fair:
        value = 0.5;
        label = 'Fair';
        break;
      case PasswordStrength.strong:
        value = 0.75;
        label = 'Strong';
        break;
      case PasswordStrength.veryStrong:
        value = 1.0;
        label = 'Very Strong';
        break;
    }

    if (mounted) {
      setState(() {
        _passwordStrength = value;
        _strengthLabel = label;
      });
    }
  }

  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedGender == null) {
      context.showErrorSnack('Please select your gender');
      return;
    }

    if (!_agreedToTerms) {
      context.showErrorSnack('Please accept the terms and conditions');
      return;
    }

    final success = await ref.read(authProvider.notifier).signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          fullName: _nameCtrl.text.trim(),
          age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
          gender: _selectedGender!,
        );

    if (success && mounted) {
      context.go(AppRoutes.home);
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
            bottom: -120,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ─── Back Button ──────────────
                    _BackButton(isDark: isDark)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.1),

                    const SizedBox(height: 24),

                    // ─── Header ───────────────────
                    _buildHeader(isDark)
                        .animate(delay: 50.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, end: 0, duration: 500.ms),

                    const SizedBox(height: 28),

                    // ─── Full Name ────────────────
                    AuthTextField(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      hint: 'John Doe',
                      focusNode: _nameFocus,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                      validator: Validators.fullName,
                    )
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, duration: 400.ms),

                    const SizedBox(height: 16),

                    // ─── Email ────────────────────
                    AuthTextField(
                      controller: _emailCtrl,
                      label: 'Email Address',
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _emailFocus,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: Validators.email,
                    )
                        .animate(delay: 150.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, duration: 400.ms),

                    const SizedBox(height: 16),

                    // ─── Password ─────────────────
                    AuthTextField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      hint: '••••••••',
                      obscureText: true,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      onFieldSubmitted: (_) => _ageFocus.requestFocus(),
                      validator: Validators.password,
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, duration: 400.ms),

                    // ─── Password strength ────────
                    if (_passwordStrength > 0)
                      PasswordStrengthIndicator(
                        strength: _passwordStrength,
                        label: _strengthLabel,
                      ).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: 16),

                    // ─── Age ──────────────────────
                    AuthTextField(
                      controller: _ageCtrl,
                      label: 'Age',
                      hint: '25',
                      keyboardType: TextInputType.number,
                      focusNode: _ageFocus,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.cake_outlined),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: Validators.age,
                    )
                        .animate(delay: 250.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, duration: 400.ms),

                    const SizedBox(height: 16),

                    // ─── Gender ───────────────────
                    _buildGenderSection(isDark)
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, duration: 400.ms),

                    const SizedBox(height: 20),

                    // ─── Terms ────────────────────
                    _buildTermsRow(isDark)
                        .animate(delay: 350.ms)
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 28),

                    // ─── Sign Up Button ───────────
                    AppButton(
                      label: 'Create Account',
                      onPressed: isLoading ? null : _signUp,
                      isLoading: isLoading,
                      style: AppButtonStyle.primary,
                      fullWidth: true,
                      height: 56,
                      leading: const Icon(Icons.person_add_rounded,
                          color: Colors.white, size: 18),
                    )
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, duration: 400.ms),

                    const SizedBox(height: 20),

                    // ─── Login link ───────────────
                    _buildLoginLink(isDark)
                        .animate(delay: 450.ms)
                        .fadeIn(duration: 400.ms),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: AppTextStyles.displaySmall(dark: isDark),
        ),
        const SizedBox(height: 6),
        Text(
          'Join millions of health-conscious users',
          style: AppTextStyles.bodyMedium(dark: isDark),
        ),
      ],
    );
  }

  Widget _buildGenderSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        GenderSelector(
          selected: _selectedGender,
          onSelect: (g) => setState(() => _selectedGender = g),
        ),
      ],
    );
  }

  Widget _buildTermsRow(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: _agreedToTerms ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _agreedToTerms
                    ? AppColors.primary
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                width: 1.5,
              ),
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTextStyles.bodySmall(dark: isDark),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            'Sign In',
            style: AppTextStyles.bodySmall(color: AppColors.primary)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final bool isDark;
  const _BackButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardSecondaryDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}
