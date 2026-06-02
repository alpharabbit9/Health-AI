import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends Equatable {
  final bool notificationsEnabled;
  final bool medicationReminders;
  final bool healthTipsEnabled;
  final bool biometricLogin;
  final String language;

  const AppSettings({
    this.notificationsEnabled = true,
    this.medicationReminders = true,
    this.healthTipsEnabled = true,
    this.biometricLogin = false,
    this.language = 'English',
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? medicationReminders,
    bool? healthTipsEnabled,
    bool? biometricLogin,
    String? language,
  }) =>
      AppSettings(
        notificationsEnabled:
            notificationsEnabled ?? this.notificationsEnabled,
        medicationReminders: medicationReminders ?? this.medicationReminders,
        healthTipsEnabled: healthTipsEnabled ?? this.healthTipsEnabled,
        biometricLogin: biometricLogin ?? this.biometricLogin,
        language: language ?? this.language,
      );

  @override
  List<Object?> get props => [
        notificationsEnabled,
        medicationReminders,
        healthTipsEnabled,
        biometricLogin,
        language,
      ];
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(),
);

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = AppSettings(
      notificationsEnabled: p.getBool('s_notifications') ?? true,
      medicationReminders: p.getBool('s_med_reminders') ?? true,
      healthTipsEnabled: p.getBool('s_health_tips') ?? true,
      biometricLogin: p.getBool('s_biometric') ?? false,
      language: p.getString('s_language') ?? 'English',
    );
  }

  Future<void> setNotifications(bool v) async {
    state = state.copyWith(notificationsEnabled: v);
    (await SharedPreferences.getInstance()).setBool('s_notifications', v);
  }

  Future<void> setMedicationReminders(bool v) async {
    state = state.copyWith(medicationReminders: v);
    (await SharedPreferences.getInstance()).setBool('s_med_reminders', v);
  }

  Future<void> setHealthTips(bool v) async {
    state = state.copyWith(healthTipsEnabled: v);
    (await SharedPreferences.getInstance()).setBool('s_health_tips', v);
  }

  Future<void> setBiometric(bool v) async {
    state = state.copyWith(biometricLogin: v);
    (await SharedPreferences.getInstance()).setBool('s_biometric', v);
  }

  Future<void> setLanguage(String v) async {
    state = state.copyWith(language: v);
    (await SharedPreferences.getInstance()).setString('s_language', v);
  }
}
