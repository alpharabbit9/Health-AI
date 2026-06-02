import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/health_ai_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    Future.delayed(AppConstants.splashDelay, _navigate);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      context.go(AppRoutes.home);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final onboardingSeen = prefs.getBool(AppConstants.onboardingSeenKey) ?? false;

    if (!mounted) return;
    if (onboardingSeen) {
      context.go(AppRoutes.login);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─── Background gradient ───────────────────
          _BackgroundGradient(pulseController: _pulseController),

          // ─── Decorative circles ───────────────────
          ..._decorativeCircles(),

          // ─── Main content ─────────────────────────
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                _buildLogo(),
                const SizedBox(height: 28),
                _buildTitle(),
                const SizedBox(height: 12),
                _buildTagline(),
                const Spacer(flex: 3),
                _buildBottomIndicator(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return HealthAILogo(size: 88, bgColor: AppColors.primary, iconColor: Colors.white)
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 700.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildTitle() {
    return Text(
      AppConstants.appName,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 42,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -1.5,
      ),
    )
        .animate(delay: 300.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildTagline() {
    return Text(
      AppConstants.appTagline,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.65),
        letterSpacing: 0.3,
        height: 1.5,
      ),
    )
        .animate(delay: 500.ms)
        .fadeIn(duration: 700.ms)
        .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildBottomIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == 1 ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == 1
                ? AppColors.primary
                : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        )
            .animate(delay: (700 + i * 100).ms)
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.5, 0.5), duration: 400.ms),
      ),
    );
  }

  List<Widget> _decorativeCircles() {
    return [
      Positioned(
        top: -120,
        right: -120,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) => Opacity(
            opacity: 0.05 + _pulseController.value * 0.05,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -150,
        left: -100,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) => Opacity(
            opacity: 0.04 + _pulseController.value * 0.04,
            child: Container(
              width: 360,
              height: 360,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

class _BackgroundGradient extends StatelessWidget {
  final AnimationController pulseController;
  const _BackgroundGradient({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(
                const Color(0xFF0F3D25),
                const Color(0xFF0A2C1B),
                pulseController.value,
              )!,
              AppColors.backgroundDark,
            ],
          ),
        ),
      ),
    );
  }
}
