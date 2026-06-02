import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, int>((ref) => OnboardingNotifier());

class OnboardingNotifier extends StateNotifier<int> {
  OnboardingNotifier() : super(0);

  void nextPage() => state++;
  void previousPage() {
    if (state > 0) state--;
  }

  void setPage(int page) => state = page;

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingSeenKey, true);
  }
}
