import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_text_styles.dart';

class SymptomsScreen extends StatelessWidget {
  const SymptomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, top + 20, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Symptom Checker',
              style: AppTextStyles.headlineLarge(dark: isDark),
            ),
            const SizedBox(height: 4),
            Text(
              'AI-powered health analysis',
              style: AppTextStyles.bodyMedium(dark: isDark),
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Coming in Part 2',
                      style: AppTextStyles.labelMedium(
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI Symptom Analysis',
                    style: AppTextStyles.headlineMedium(dark: isDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Describe your symptoms and receive\ninstant AI-powered analysis and\npersonalised recommendations.',
                    style: AppTextStyles.bodyMedium(dark: isDark),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'What to expect',
              style: AppTextStyles.titleLarge(dark: isDark),
            ),
            const SizedBox(height: 16),
            ..._kFeatures.map(
              (f) => _FeatureTile(
                emoji: f.$1,
                title: f.$2,
                subtitle: f.$3,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _kFeatures = [
  ('🤖', 'AI-Powered Analysis', 'Groq AI analyses your symptoms in seconds'),
  ('📊', 'Risk Assessment', 'Get a clear Low / Medium / High risk rating'),
  ('💊', 'Smart Recommendations', 'Personalised health advice and next steps'),
  ('📋', 'Saved Reports', 'Export and share your health reports as PDF'),
];

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall(dark: isDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall(dark: isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
