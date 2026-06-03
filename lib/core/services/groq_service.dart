import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/env.dart';

const _groqBase = 'https://api.groq.com/openai/v1/chat/completions';
const _model = 'llama-3.3-70b-versatile';
const _maxRetries = 3;

const _systemPrompt = '''
You are HealthAI, a medical information assistant. You help users understand their symptoms.

STRICT RULES:
1. NEVER definitively diagnose a condition
2. ALWAYS recommend consulting a qualified healthcare professional
3. Provide ONLY informational guidance, never medical advice
4. Return ONLY valid JSON — no markdown, no explanations outside JSON
5. If symptoms suggest a medical emergency, set risk_level to "high" and include clear emergency_warnings

Analyse the patient's symptoms and respond with this exact JSON structure:
{
  "risk_level": "low" | "moderate" | "high",
  "summary": "2-3 sentence overview of the analysis",
  "possible_conditions": [
    {
      "name": "Condition Name",
      "confidence": 75,
      "description": "Brief explanation of why this matches the symptoms"
    }
  ],
  "recommendations": [
    {
      "title": "Short action title",
      "description": "Detailed recommendation",
      "type": "rest|water|hospital|pill|monitor|food|exercise"
    }
  ],
  "self_care_advice": "Practical self-care tips the patient can follow at home",
  "emergency_warnings": ["Warning if symptoms suggest urgency — omit array if no warnings"],
  "when_to_see_doctor": "Clear guidance on when to seek professional medical care",
  "recommended_specialty": "The single most relevant medical specialty from this list ONLY: General, Cardiology, Dermatology, ENT, Gastroenterology, Neurology, Paediatrics, Orthopaedics. Choose General if no specific specialty applies.",
  "disclaimer": "This analysis is for informational purposes only and does not constitute medical advice. Always consult a qualified healthcare professional for diagnosis and treatment."
}
''';

class GroqService {
  GroqService._();
  static final GroqService instance = GroqService._();

  Future<Map<String, dynamic>> analyzeSymptoms({
    required List<String> symptoms,
    required String duration,
    required int severity,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
  }) async {
    if (!Env.hasGroqKey) {
      return _mockResponse(symptoms, severity);
    }

    final userMessage = _buildPrompt(
      symptoms: symptoms,
      duration: duration,
      severity: severity,
      age: age,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
    );

    for (var attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final response = await http
            .post(
              Uri.parse(_groqBase),
              headers: {
                'Authorization': 'Bearer ${Env.groqApiKey}',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': _model,
                'messages': [
                  {'role': 'system', 'content': _systemPrompt},
                  {'role': 'user', 'content': userMessage},
                ],
                'response_format': {'type': 'json_object'},
                'temperature': 0.3,
                'max_tokens': 1500,
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final content =
              body['choices'][0]['message']['content'] as String;
          return jsonDecode(content) as Map<String, dynamic>;
        }

        if (response.statusCode == 429) {
          // Rate limited — wait before retry
          await Future.delayed(Duration(seconds: attempt * 2));
          continue;
        }

        throw Exception(
            'Groq API error ${response.statusCode}: ${response.body}');
      } catch (e) {
        debugPrint('[HealthAI] Groq attempt $attempt failed: $e');
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }

    debugPrint('[HealthAI] All Groq retries failed, using fallback');
    return _mockResponse(symptoms, severity);
  }

  String _buildPrompt({
    required List<String> symptoms,
    required String duration,
    required int severity,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
  }) {
    final profile = StringBuffer('Patient profile:\n');
    if (age != null) profile.writeln('- Age: $age years');
    if (gender != null) profile.writeln('- Gender: $gender');
    if (heightCm != null) profile.writeln('- Height: ${heightCm.toStringAsFixed(0)} cm');
    if (weightKg != null) profile.writeln('- Weight: ${weightKg.toStringAsFixed(1)} kg');

    return '''
$profile
Reported symptoms: ${symptoms.join(', ')}
Duration: $duration
Severity: $severity/10

Please provide a comprehensive health assessment.
''';
  }

  // Fallback when Groq key is not configured or all retries fail
  Map<String, dynamic> _mockResponse(List<String> symptoms, int severity) {
    final risk = severity >= 8
        ? 'high'
        : severity >= 5
            ? 'moderate'
            : 'low';

    return {
      'risk_level': risk,
      'summary':
          'Based on your reported symptoms (${symptoms.take(3).join(', ')}), '
              'this appears to be a $risk severity situation. '
              'Please consult a healthcare professional for proper evaluation.',
      'possible_conditions': [
        {
          'name': 'Viral Infection',
          'confidence': 60,
          'description':
              'Common viral infections can cause many of these symptoms.',
        },
        {
          'name': 'Stress-related condition',
          'confidence': 40,
          'description':
              'Stress and fatigue can manifest as physical symptoms.',
        },
      ],
      'recommendations': [
        {
          'title': 'Rest',
          'description':
              'Get plenty of rest to allow your body to recover.',
          'type': 'rest',
        },
        {
          'title': 'Stay Hydrated',
          'description': 'Drink 8–10 glasses of water throughout the day.',
          'type': 'water',
        },
        {
          'title': 'Monitor Symptoms',
          'description':
              'Track your symptoms and note any changes in severity.',
          'type': 'monitor',
        },
        {
          'title': 'Consult a Doctor',
          'description':
              'Schedule an appointment if symptoms persist or worsen.',
          'type': 'hospital',
        },
      ],
      'self_care_advice':
          'Rest, stay hydrated, and avoid strenuous activities. '
              'Over-the-counter medications may help manage discomfort.',
      'emergency_warnings': severity >= 8
          ? ['Seek immediate medical attention if symptoms worsen rapidly']
          : [],
      'when_to_see_doctor':
          'See a doctor if symptoms persist beyond 3 days, '
              'worsen significantly, or if you develop a high fever.',
      'disclaimer':
          'This analysis is for informational purposes only and does not '
              'constitute medical advice. Always consult a qualified healthcare '
              'professional for diagnosis and treatment.',
    };
  }
}
