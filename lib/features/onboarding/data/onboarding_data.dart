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

enum IllustrationType {
  aiAnalysis,
  findDoctors,
  healthHistory,
  recommendations
}

final onboardingItems = [
  const OnboardingItem(
    illustration: IllustrationType.aiAnalysis,
    title: 'AI Symptom Analysis',
    subtitle:
        'Describe how you feel and our AI instantly identifies potential health concerns with medical-grade accuracy.',
    gradientColors: [
      Color(0xFFEAFBF1),
      Color(0xFFC5F0D9),
    ],
  ),
  const OnboardingItem(
    illustration: IllustrationType.findDoctors,
    title: 'Find Nearby Doctors',
    subtitle:
        'Locate top-rated specialists near you, compare profiles, and book appointments in seconds.',
    gradientColors: [
      Color(0xFFEFF6FF),
      Color(0xFFDBEAFE),
    ],
  ),
  const OnboardingItem(
    illustration: IllustrationType.healthHistory,
    title: 'Health History Tracking',
    subtitle:
        'Maintain a complete timeline of your health journey, medications, and visits in one secure place.',
    gradientColors: [
      Color(0xFFFFFBEB),
      Color(0xFFFEF3C7),
    ],
  ),
  const OnboardingItem(
    illustration: IllustrationType.recommendations,
    title: 'Personalized Recommendations',
    subtitle:
        'Receive daily health tips, diet plans, and wellness goals tailored specifically to your profile.',
    gradientColors: [
      Color(0xFFF5F3FF),
      Color(0xFFEDE9FE),
    ],
  ),
];
