import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingItem {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final IllustrationType illustration;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.illustration,
  });
}

enum IllustrationType { aiAnalysis, findDoctors, healthHistory, recommendations }

final onboardingItems = [
  OnboardingItem(
    illustration: IllustrationType.aiAnalysis,
    title: 'AI Symptom Analysis',
    subtitle:
        'Describe how you feel and our AI instantly identifies potential health concerns with medical-grade accuracy.',
    gradientColors: [
      const Color(0xFFEAFBF1),
      const Color(0xFFC5F0D9),
    ],
  ),
  OnboardingItem(
    illustration: IllustrationType.findDoctors,
    title: 'Find Nearby Doctors',
    subtitle:
        'Locate top-rated specialists near you, compare profiles, and book appointments in seconds.',
    gradientColors: [
      const Color(0xFFEFF6FF),
      const Color(0xFFDBEAFE),
    ],
  ),
  OnboardingItem(
    illustration: IllustrationType.healthHistory,
    title: 'Health History Tracking',
    subtitle:
        'Maintain a complete timeline of your health journey, medications, and visits in one secure place.',
    gradientColors: [
      const Color(0xFFFFFBEB),
      const Color(0xFFFEF3C7),
    ],
  ),
  OnboardingItem(
    illustration: IllustrationType.recommendations,
    title: 'Personalized Recommendations',
    subtitle:
        'Receive daily health tips, diet plans, and wellness goals tailored specifically to your profile.',
    gradientColors: [
      const Color(0xFFF5F3FF),
      const Color(0xFFEDE9FE),
    ],
  ),
];
