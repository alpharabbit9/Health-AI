import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/health_record.dart';

final healthRecordsProvider =
    StateNotifierProvider<HealthRecordsNotifier, List<HealthRecord>>(
  (ref) => HealthRecordsNotifier(),
);

class HealthRecordsNotifier extends StateNotifier<List<HealthRecord>> {
  HealthRecordsNotifier() : super(_mockRecords());

  void addRecord(HealthRecord record) => state = [record, ...state];

  void deleteRecord(String id) =>
      state = state.where((r) => r.id != id).toList();
}

List<HealthRecord> _mockRecords() => [
      HealthRecord(
        id: '1',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        symptoms: const ['Headache', 'Fatigue', 'Eye strain'],
        riskLevel: RiskLevel.low,
        possibleConditions: 'Tension headache, Digital eye strain',
        aiRecommendations:
            'Rest your eyes every 20 minutes using the 20-20-20 rule. Stay well-hydrated and take OTC pain relievers if needed. Reduce screen time before bed.',
      ),
      HealthRecord(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        symptoms: const ['Fever 101°F', 'Cough', 'Sore throat', 'Body aches'],
        riskLevel: RiskLevel.medium,
        possibleConditions: 'Common cold, Influenza, Upper respiratory infection',
        aiRecommendations:
            'Rest, stay hydrated, and take fever reducers. Monitor temperature closely. Consult a doctor if fever exceeds 103°F or persists beyond 3 days.',
      ),
      HealthRecord(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 3)),
        symptoms: const ['Stomach cramps', 'Nausea', 'Bloating'],
        riskLevel: RiskLevel.low,
        possibleConditions: 'Indigestion, Gastritis, IBS flare',
        aiRecommendations:
            'Avoid spicy, fatty, and acidic foods. Try the BRAT diet (Bananas, Rice, Applesauce, Toast). Antacids may help. See a doctor if symptoms persist.',
      ),
      HealthRecord(
        id: '4',
        date: DateTime.now().subtract(const Duration(days: 7)),
        symptoms: const ['Shortness of breath', 'Chest tightness', 'Dry cough'],
        riskLevel: RiskLevel.high,
        possibleConditions:
            'Asthma exacerbation, Allergic reaction, Anxiety attack',
        aiRecommendations:
            'Seek medical attention promptly. Use your rescue inhaler if prescribed. Avoid known allergens. If symptoms are severe or worsening, call emergency services immediately.',
      ),
    ];
